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

const vec3 ambientLight = vec3(0.0, 0.0, 0.0);

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


float zOnPlane(vec2 xy, vec3 pointOnPlane, vec3 planeNormal) {

    return pointOnPlane.z - (planeNormal.x * (xy.x - pointOnPlane.x) + 
                             planeNormal.y * (xy.y - pointOnPlane.y)) / planeNormal.z;

}

bool rayOcclusionCheck(vec3 rayPos, vec2 terrainCell) {

    vec2 terrainUV = toUV(vec3(terrainCell.x, terrainCell.y, 0.0));
    float terrainHeight = getZ(terrainUV);
    vec3 terrainNormal = texture(normalMap, terrainUV).xyz;
    vec3 terrainSample = vec3(terrainCell.x, terrainCell.y, terrainHeight);

    return (rayPos.z < zOnPlane(rayPos.xy, terrainSample, terrainNormal));
}

bool debugOcclusionCheck(vec3 rayPos, vec2 terrainCell) {
    
    vec2 terrainUV = toUV(vec3(terrainCell.x, terrainCell.y, 0.0));
    float terrainHeight = getZ(terrainUV);

    return (rayPos.z < terrainHeight);
}


// Ray march from fragment to light source
vec3 pointLighting() {
    vec3 totalLight = vec3(0.0);
    float shadowSoftness = 1.5;

    for (int i = 0; i < numPointLightsInUse; i++) {
        PointLight light = pointLights[i];

        for (int j = 0; j < NUM_RAYS; j++) {

            vec3 fragPos = vec3(v_positionWorld.xy, getZ(v_uv));
            vec3 offset = rayOffsets[j] * shadowSoftness;
            vec3 lightPos = light.positionWorld + offset;
            vec3 displacement = lightPos - fragPos;

            if (length(displacement) > light.radius) continue;

            vec3 normal = normalize(texture(normalMap, v_uv).rgb * 2.0 - 1.0);
            float normalFactor = max(dot(normal, normalize(displacement)), 0.0);
            if (normalFactor == 0.0) continue;

            // DDA Setup
            vec2 step = sign(displacement.xy);
            // step.x = 0
            // step.y = 1
            vec2 tStep;
            vec2 tTillNextBound;
            vec2 currCell = fragPos.xy;
            vec2 firstBound = currCell + step;

        
            // displacement.x = 0
            // tStep.x = 1.0e5
            // tTillNextBound.x = 1.0e5
            if (displacement.x  == 0.0) {
                tStep.x = 1.0;
                tTillNextBound.x = 1.0;
            } else {
                tStep.x = abs(1.0 / displacement.x);
                tTillNextBound.x = abs((firstBound.x - fragPos.x) / displacement.x);
            }

            // displacement.y = 10
            // tStep.y = 0.1
            // tTillNextBound.y = 0.1
            if (displacement.y == 0.0) {
                tStep.y = 1.0;
                tTillNextBound.y = 1.0;
            } else {
                tStep.y = abs(1.0 / displacement.y);
                tTillNextBound.y = abs((firstBound.y - fragPos.y) / displacement.y);
            }
            
            float rayFactor = 1.0;

            // t = 0.1
            float t = min(tTillNextBound.x, tTillNextBound.y);

            vec3 debugColor = vec3(1.0, 1.0, 1.0);
            while (t < 1.0) {

                if (t < 0.0) {
                    debugColor = vec3(1.0, 0.0, 0.0);
                    break;
                }
                
                vec3 rayCurrPos = mix(fragPos, lightPos, t);

                vec2 currStep;
                debugColor.r -= 0.01;
                debugColor.g -= 0.01;
                debugColor.b -= 0.01;
                // Step DDA
                if (tTillNextBound.x < tTillNextBound.y) {
                    tTillNextBound.x += tStep.x;
                    t = tTillNextBound.x;
                    currStep = vec2(step.x, 0.0);


                } else {
                    tTillNextBound.y += tStep.y;
                    t = tTillNextBound.y;
                    // t = 0.2
                    // t = 0.2
                    currStep = vec2(0.0, step.y);
                    // currStep = (0.0, 1.0);

                    // debugColor.g += 0.02;

                }

                // fragPos = (0, -10)
                // lightPos = (0, 0)
                // rayCurrPos = 0.9 fragPos + 0.1 lightPos
                // rayCurrPos = (0, -9)
                // currCell = (0, -10)
                // Check exiting current cell
                // if (debugOcclusionCheck(rayCurrPos, currCell)) {
                //     rayFactor = 0.0;
                //     break;
                // }

                currCell += currStep;

                // Check entering next cell
                if (debugOcclusionCheck(rayCurrPos, currCell)) {
                    rayFactor = 0.0;
                    break;
                }
            }

            if (rayFactor == 0.0) continue;

            // vec3 color = lightWithDistance(light, length(displacement));
            // float rayWeight = 1.0 / float(NUM_RAYS);
            // totalLight += rayWeight * normalFactor * color;
            debugColor = max(debugColor, 0.0);
            totalLight += debugColor;
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