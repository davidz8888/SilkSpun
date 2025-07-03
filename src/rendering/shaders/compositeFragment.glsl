precision highp float;

in vec3 v_positionWorld;
in vec2 v_uv;

uniform float screenWidth;
uniform float screenHeight;


uniform sampler2D heightMap;
uniform sampler2D backgroundMap; 
uniform sampler2D foregroundMap;
uniform sampler2D hydraulicsMap;
uniform sampler2D initialVelocityMap;
uniform sampler2D injectedVelocityMap;
uniform sampler2D advectedVelocityMap;
uniform sampler2D projectedVelocityMap;
uniform sampler2D matterMap;
uniform sampler2D divergenceMap;
uniform sampler2D pressureMapA;
uniform sampler2D pressureMapB;

out vec4 fragColor;

struct PointLight {
    vec3 positionWorld;
    vec3 color;
    float falloff;
    float radius;
};
#define MAX_POINTLIGHTS 100
uniform PointLight pointLights[MAX_POINTLIGHTS];
uniform int numPointLightsInUse;

#define MAX_SIMPLELIGHTS 100
uniform PointLight simpleLights[MAX_SIMPLELIGHTS];
uniform int numSimpleLightsInUse;


struct InfiniteLight {
    vec3 direction;
    vec3 color;
    float shadowDistance;
};

#define NUM_INFINITELIGHTS 10
uniform InfiniteLight infiniteLights[NUM_INFINITELIGHTS];
uniform int numInfiniteLightsInUse;

float FLUID_Z = -60.0;


vec2 toUV(vec2 worldPos) { 
    return vec2(worldPos.x/screenWidth, worldPos.y/screenHeight) + 0.5;
}

vec4 safeColor(vec4 c) {
    return (c.r != c.r) ? vec4(0.0, 1.0, 0.0, 1.0) : c;
}

vec4 velocityToColor(vec4 velocity) {

    float red = velocity.x + 0.5;
    float green = velocity.y + 0.5;
    float blue = 0.5;
    return vec4(red, green, blue, 1.0);
}

float getZ(vec2 uv) {
    vec4 fragZInfo = texture(heightMap, uv);

    if (fragZInfo.b <= 0.0) {
        return -10000.0;
    } else {
        return fragZInfo.r;
    }

}

bool simpleOcclusionCheck(vec3 rayPos, vec2 terrainCell) {
    
    vec2 terrainUV = toUV(terrainCell.xy);
    float terrainHeight = getZ(terrainUV);

    return (rayPos.z < terrainHeight);
}


vec3 lightWithDistance(PointLight light, float distance) {
    return light.color * ((light.radius - distance) / ((light.falloff * distance * distance) + light.radius));
} 

bool DDAOcclusionCheck(vec3 startPoint, vec3 endPoint) {

    float LARGE_NUMBER = 10000.0;

    vec3 displacement = endPoint - startPoint;
    vec2 step = sign(displacement.xy);
    vec2 tStep;
    vec2 tCurrBound;
    vec2 currCell = startPoint.xy;
    vec2 firstBound = currCell + step;

    if (displacement.x  == 0.0) {
        tStep.x = 1.0;
        tCurrBound.x = LARGE_NUMBER;
    } else {
        tStep.x = abs(1.0 / displacement.x);
        tCurrBound.x = abs((firstBound.x - startPoint.x) / displacement.x);
    }

    if (displacement.y == 0.0) {
        tStep.y = 1.0;
        tCurrBound.y = LARGE_NUMBER;
    } else {
        tStep.y = abs(1.0 / displacement.y);
        tCurrBound.y = abs((firstBound.y - startPoint.y) / displacement.y);
    }

    bool occluded = false;
    float t = 0.0;
    vec2 currStep;

    while (t < 1.0) {

        // Step DDA
        if (tCurrBound.x < tCurrBound.y) {
            t = tCurrBound.x;
            tCurrBound.x += tStep.x;
            currStep = vec2(step.x, 0.0);

        } else {
            t = tCurrBound.y;
            tCurrBound.y += tStep.y;
            currStep = vec2(0.0, step.y);
        }

        vec3 rayCurrPos = mix(startPoint, endPoint, t);

        // Check exiting current cell
        if (simpleOcclusionCheck(rayCurrPos, currCell)) {
            occluded = true;
            break;
        }

        currCell += currStep;

        // Check entering next cell
        if (simpleOcclusionCheck(rayCurrPos, currCell)) {
            occluded = true;
            break;
        }
    }

    return occluded;
}


vec3 pointLightingFluid() {

    vec3 totalColor = vec3(0.0);

    for (int i = 0; i < numPointLightsInUse; i++) {
        PointLight light = pointLights[i];

        vec3 fragPos = vec3(v_positionWorld.xy, FLUID_Z);
        vec3 lightPos = light.positionWorld;
        vec3 displacement = lightPos - fragPos;

        if (length(displacement) > light.radius) continue;

        if (DDAOcclusionCheck(fragPos, lightPos)) continue;

        // vec3 lightColor = lightWithDistance(light, length(displacement));
        vec3 lightColor = light.color;
        vec4 matter = texture(matterMap, v_uv);
        vec3 matterColor = matter.rgb;
        vec3 color = matterColor * lightColor;

        color = clamp(color, 0.0, 1.0);
        totalColor += color;
    }

    return totalColor;
}

vec3 infiniteLightingFluid() {

    vec3 totalColor = vec3(0);

    for (int i = 0; i < numInfiniteLightsInUse; i++) {
        
        InfiniteLight light = infiniteLights[i];

        vec3 fragPos = vec3(v_positionWorld.xy, FLUID_Z);
        vec3 lightDir = normalize(light.direction);

        vec3 lightPos = fragPos + (lightDir * light.shadowDistance);

        // DDA Setup
        if (DDAOcclusionCheck(fragPos, lightPos)) continue;

        vec4 matter = texture(matterMap, v_uv);
        vec3 matterColor = matter.rgb;
        vec3 color = matterColor * light.color;
        
        
        color = clamp(color, 0.0, 1.0);
        totalColor += color;
    }

    return totalColor;
}

void main() {

    vec4 background = texture(backgroundMap, v_uv);
    vec4 foreground = texture(foregroundMap, v_uv);
    vec4 hydraulics = texture(hydraulicsMap, v_uv);

    vec4 initialVelocity = texture(initialVelocityMap, v_uv);
    vec4 injectedVelocity = texture(injectedVelocityMap, v_uv);
    vec4 advectedVelocity = texture(advectedVelocityMap, v_uv);
    vec4 projectedVelocity = texture(projectedVelocityMap, v_uv);
    vec4 matter = texture(matterMap, v_uv);
    vec4 divergence = texture(divergenceMap, v_uv);
    vec4 pressureA = texture(pressureMapA, v_uv);
    vec4 pressureB = texture(pressureMapB, v_uv);

    // vec3 solidsColor = (foreground.a * foreground.rgb) + ((1.0 - foreground.a) * background.rgb);


    vec3 litMatter = pointLightingFluid() * 2.0 + infiniteLightingFluid();
    vec3 combinedColor = litMatter + ((1.0 - matter.a) * foreground.rgb);
    
    // fragColor = foreground;
    // fragColor = vec4(solidsColor.r, solidsColor.g, solidsColor.b, 1.0);
    fragColor = vec4(combinedColor, background.a + foreground.a + matter.a);
           
    // fragColor = vec4(matter.a);
    vec4 coloredPressure = safeColor(vec4(pressureA.r, 0.0, -pressureA.r, 1.0));
    vec4 coloredDivergence = vec4(-divergence.r, 0.0, divergence.r, 0.0);
    
    // fragColor = vec4(matter.a);
    
    // fragColor = safeColor(coloredPressure);
    // fragColor = matter;
    // fragColor = coloredDivergence * 5.0;
    // fragColor = velocityToColor(initialVelocity);
    // fragColor = velocityToColor(injectedVelocity);
    // fragColor = velocityToColor(advectedVelocity);
    // fragColor = velocityToColor(projectedVelocity);

    // fragColor = coloredPressure;
    // fragColor = hydraulics;
    // fragColor = safeColor(vec4(abs(velocity.r)));
    // fragColor = vec4(velocity.y);
    // fragColor = velocity;

    vec2 base = floor(v_positionWorld.xy);
    vec2 frac = v_positionWorld.xy - base;

    // fragColor = vec4(frac.x, frac.y, 0.0, 1.0);
}