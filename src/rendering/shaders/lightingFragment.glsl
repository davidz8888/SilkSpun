// #version 300 es
// precision mediump float;

// G-buffer inputs
in vec3 v_positionWorld;
in vec2 v_uv;

uniform float screenWidth;
uniform float screenHeight;

uniform sampler2D albedoMap; 
uniform sampler2D normalMap;
uniform sampler2D heightMap;

out vec4 fragColor;

const float HEIGHT_SCALING = 8.0;

// #define NUM_RAYS 9
// const vec3 rayOffsets[NUM_RAYS] = vec3[NUM_RAYS](
//     vec3(0.0, 0.0, 0.0),
//     vec3(0.25, 0.25, 0.25),
//     vec3(0.25, -0.25, 0.25),
//     vec3(-0.25, 0.25, 0.25),
//     vec3(-0.25, -0.25, 0.25),
//     vec3(0.25, 0.25, -0.25),
//     vec3(0.25, -0.25, -0.25),
//     vec3(-0.25, 0.25, -0.25),
//     vec3(-0.25, -0.25, -0.25)
// );
#define NUM_RAYS 1
const vec3 rayOffsets[NUM_RAYS] = vec3[NUM_RAYS](
    vec3(0.0, 0.0, 0.0)
);

struct PointLight {
    vec3 positionWorld;
    vec3 color;
    float falloff;
    float radius;
};
#define MAX_POINTLIGHTS 100
uniform PointLight pointLights[MAX_POINTLIGHTS];
uniform int numPointLightsInUse;

struct SkyLight {
    vec3 color;
    float shadowDistance;
};
uniform SkyLight skyLight;
#define NUM_SKYLIGHTS 6
const vec3 skyLightDirections[NUM_SKYLIGHTS] = vec3[NUM_SKYLIGHTS](
    vec3(0.0, 1.0, 0.0),
    vec3(1.0, 1.0, 0.0),
    vec3(-1.0, 1.0, 0.0),
    vec3(0.0, 1.0, 1.0),
    vec3(0.333, 1.0, 0.333),
    vec3(-0.333, 1.0, 0.333)
);


struct InfiniteLight {
    vec3 direction;
    vec3 color;
    float shadowDistance;
};

#define NUM_INFINITELIGHTS 10
uniform InfiniteLight infiniteLights[NUM_INFINITELIGHTS];
uniform int numInfiniteLightsInUse;

const vec3 ambientLight = vec3(0.05, 0.05, 0.03);

vec3 lightWithDistance(PointLight light, float distance) {
    return light.color * ((light.radius - distance) / ((light.falloff * distance * distance) + light.radius));
}   

vec3 debugLight(PointLight light, float distance) {
    return (light.radius > distance) ? vec3(1.0) : vec3(0.0);
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

    if (fragZInfo.b != 1.0) {
        return -100.0;
    } else {
        return (fragZInfo.r * -100.0) + (fragZInfo.g * HEIGHT_SCALING);
    }

}



vec3 pointLighting() {
    vec3 totalLight = vec3(0.0);
    float shadowSoftness = 1.5;

    for (int i = 0; i < numPointLightsInUse; i++) {
        PointLight light = pointLights[i];

        for (int j = 0; j < NUM_RAYS; j++) {
            vec3 fragPos = vec3(v_positionWorld.xy, getZ(v_uv));
            vec3 offset = rayOffsets[j] * shadowSoftness;
            vec3 lightPos = light.positionWorld + offset;
            vec3 delta = lightPos - fragPos;

            if (length(delta) > light.radius) continue;

            vec3 normal = normalize(texture(normalMap, v_uv).rgb * 2.0 - 1.0);
            float normalFactor = max(dot(normal, normalize(delta)), 0.0);
            if (normalFactor == 0.0) continue;

            // DDA Setup
            vec2 dir = delta.xy;
            vec2 step = sign(dir);
            vec2 tDelta = abs(vec2(1.0) / dir);
            
            vec2 rayCell = floor(fragPos.xy);
            vec2 nextBoundary = rayCell + step * 0.5 + 0.5 * step; // center of next voxel
            vec2 tMax = abs((nextBoundary - fragPos.xy) / dir);

            float totalDist = length(dir);
            float traveled = 0.0;
            float rayZStart = fragPos.z;
            float rayZEnd = lightPos.z;

            vec2 currentPos = fragPos.xy;
            float rayFactor = 1.0;

            while (traveled < totalDist) {
                // Interpolated Z along the ray
                float t = traveled / totalDist;
                float rayZ = mix(rayZStart, rayZEnd, t);
                float terrainZ = getZ(toUV(vec3(currentPos, 0.0)));

                if (rayZ < terrainZ) {
                    rayFactor = 0.0;
                    break;
                }

                // Step DDA
                if (tMax.x < tMax.y) {
                    tMax.x += tDelta.x;
                    currentPos.x += step.x;
                } else {
                    tMax.y += tDelta.y;
                    currentPos.y += step.y;
                }

                traveled = length(currentPos - fragPos.xy);
            }

            if (rayFactor == 0.0) continue;

            vec3 color = lightWithDistance(light, length(delta));
            float rayWeight = 1.0 / float(NUM_RAYS);
            totalLight += rayWeight * normalFactor * color;
        }
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
        
        vec3 normal = normalize(texture(normalMap, v_uv).rgb * 2.0 - 1.0);
        float normalFactor = max((dot(normal, rayStep)), 0.0);
        if (normalFactor == 0.0) continue;

        vec3 rayPosition = fragPosition;
        float rayFactor = 1.0;

        float rayTraversalDistance = skyLight.shadowDistance;
        float rayStepDistance = stepSize * length(rayStep.xy);

        for (float j = 0.0; j < rayTraversalDistance; j += rayStepDistance) {
            
            rayPosition += (stepSize * rayStep);
            
            float currZ = getZ(toUV(rayPosition));

            rayFactor = (rayPosition.z < currZ) ? 0.0 : 1.0; 
            if (rayFactor == 0.0) break;

        }

        totalLight += (normalFactor * rayFactor * skyLight.color) / float(NUM_SKYLIGHTS);
    }

    return totalLight;
}

vec3 infiniteLighting() {

    vec3 totalLight = vec3(0);

    for (int i = 0; i < numInfiniteLightsInUse; i++) {

        InfiniteLight light = infiniteLights[i];
        vec3 fragPosition = vec3(v_positionWorld.xy, getZ(v_uv));

        vec3 rayStep = light.direction;
        float stepSize = 1.0;
        
        vec3 normal = normalize(texture(normalMap, v_uv).rgb * 2.0 - 1.0);
        float normalFactor = max((dot(normal, normalize(rayStep))), 0.0);
        if (normalFactor == 0.0) continue;

        vec3 rayPosition = fragPosition;
        float rayFactor = 1.0;

        float rayStepDistance = stepSize * length(rayStep.xy);

        for (float j = 0.0; j < light.shadowDistance; j += rayStepDistance) {
            
            rayPosition += (stepSize * rayStep);
            
            float currZ = getZ(toUV(rayPosition));

            rayFactor = (rayPosition.z < currZ) ? 0.0 : 1.0; 
            if (rayFactor == 0.0) break;

        }

        totalLight += (normalFactor * rayFactor * light.color);
    }

    return totalLight;
}

vec3 ambientLighting() {
    return vec3(0.05, 0.05, 0.05);
} 


void main() {

    vec3 absorbedLight = clamp(ambientLighting() + infiniteLighting() + skyLighting() + pointLighting(), 0.0, 1.0);

    vec4 albedo = texture(albedoMap, v_uv);

    fragColor = vec4(albedo.rgb * absorbedLight, albedo.a);
}