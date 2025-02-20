// #version 300 es
// precision mediump float;

// G-buffer inputs
in vec3 v_positionWorld;
in vec3 v_normalWorld;
in vec2 v_uv;

uniform float screenWidth;
uniform float screenHeight;

uniform sampler2D albedoMap; 
uniform sampler2D normalMap;
uniform sampler2D heightMap;

out vec4 fragColor;

struct PointLight {
    vec3 positionWorld;
    vec3 color;
    float falloff;
    float radius;
};

struct SkyLight {
    vec3 color;
    float shadowDistance;
};

struct InfiniteLight {
    vec3 direction;
    vec3 color;
    float shadowDistance;
};

const float HEIGHT_SCALING = 2.0;
#define NUM_POINTLIGHTS 4
#define NUM_SKYLIGHTS 6

const vec3 skyLightDirections[NUM_SKYLIGHTS] = vec3[NUM_SKYLIGHTS](
    vec3(0.0, 1.0, 0.0),
    vec3(1.0, 1.0, 0.0),
    vec3(-1.0, 1.0, 0.0),
    vec3(0.0, 1.0, 1.0),
    vec3(0.333, 1.0, 0.333),
    vec3(-0.333, 1.0, 0.333)
);

uniform PointLight pointLights[NUM_POINTLIGHTS];
uniform SkyLight skyLight;
uniform InfiniteLight infiniteLight;

const vec3 ambientLight = vec3(0.05, 0.05, 0.03);

vec3 lightWithDistance(PointLight light, float distance) {
    return light.color * ((light.radius - distance) / ((light.falloff * distance * distance) + light.radius));

}

bool locationEquality(vec3 posA, vec3 posB, float epsilon) {
    return length(posA - posB) < epsilon;
}

vec2 toUV(vec3 worldPos) { 
    return vec2(worldPos.x/screenWidth, worldPos.y/screenHeight) + 0.5;
}

vec3 toUnitCube(vec3 v) {
    return v / max(abs(v.x), abs(v.y));
}

float getZ(vec2 uv) {
    vec4 fragZInfo = texture(heightMap, uv);
    return (fragZInfo.r * -100.0) + (fragZInfo.g * HEIGHT_SCALING);
}

vec3 pointLighting() {

    vec3 totalLight = vec3(0);

    for (int i = 0; i < 4; i++) {

        vec3 fragPosition = vec3(v_positionWorld.xy, getZ(v_uv));

        PointLight light = pointLights[i];

        vec3 displacement = light.positionWorld - fragPosition;
        vec3 rayStep = toUnitCube(displacement);
        float stepSize = 1.0;
        
        vec3 normal = texture(normalMap, v_uv).rgb;
        float normalFactor = max((dot(normal, normalize(displacement))), 0.0);
        if (normalFactor == 0.0) continue;

        float distanceFactor = step(length(displacement) - light.radius, 0.0);
        if (distanceFactor == 0.0) continue;

        vec3 rayPosition = fragPosition;
        float rayFactor = 1.0;

        float rayTraversalDistance = length(displacement.xy);
        float rayStepDistance = stepSize * length(rayStep.xy);

        for (float j = 0.0; j < rayTraversalDistance; j += rayStepDistance) {
            
            rayPosition += (stepSize * rayStep);
            
            float rayTop = rayPosition.z + 1.0;
            float currZ = getZ(toUV(rayPosition));
            rayFactor = min(max(rayTop - currZ, 0.0), rayFactor); 
            if (rayFactor == 0.0) break;

        }

        if (rayFactor == 0.0) continue;
        
        totalLight += (normalFactor * rayFactor * lightWithDistance(light, length(displacement)));

    }

    return totalLight;
}


vec3 skyLighting() {

    vec3 totalLight = vec3(0);

    for (int i = 0; i < NUM_SKYLIGHTS; i++) {

        vec3 fragPosition = vec3(v_positionWorld.xy, getZ(v_uv));

        vec3 lightDirection = skyLightDirections[i];

        vec3 rayStep = lightDirection;
        float stepSize = 1.0;
        
        vec3 normal = texture(normalMap, v_uv).rgb;
        float normalFactor = max((dot(normal, rayStep)), 0.0);
        if (normalFactor == 0.0) continue;

        vec3 rayPosition = fragPosition;
        float rayFactor = 1.0;

        float rayTraversalDistance = skyLight.shadowDistance;
        float rayStepDistance = stepSize * length(rayStep.xy);

        for (float j = 0.0; j < rayTraversalDistance; j += rayStepDistance) {
            
            rayPosition += (stepSize * rayStep);
            
            float rayTop = rayPosition.z + 1.0;
            float currZ = getZ(toUV(rayPosition));
            rayFactor = min(max(rayTop - currZ, 0.0), rayFactor); 
            if (rayFactor == 0.0) break;

        }

        totalLight += (normalFactor * rayFactor * skyLight.color);
    }

    // return skyLight.color;
    return totalLight / float(NUM_SKYLIGHTS);
}

vec3 infiniteLighting() {
    return texture(heightMap, v_uv).g * ambientLight;
}

vec3 ambientLighting() {
    return ambientLight;
}


void main() {

    // vec3 absorbedLight = pointLighting() + ambientLighting();
    vec3 absorbedLight = skyLighting() + pointLighting();

    fragColor = vec4(texture(albedoMap, v_uv).rgb * absorbedLight, 1.0);

}