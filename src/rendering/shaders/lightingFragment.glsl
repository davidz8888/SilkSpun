// #version 300 es
// precision mediump float;

// G-buffer inputs
in vec3 v_positionWorld;
in vec3 v_viewPositionWorld;
in vec2 v_uv;

uniform float screenWidth;
uniform float screenHeight;

uniform sampler2D albedoMap; 
uniform sampler2D normalMap;
uniform sampler2D heightMap;
uniform sampler2D roughnessMap;
uniform sampler2D metalnessMap;

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

    vec2 terrainCellCenter = terrainCell += 0.5;
    vec2 terrainUV = toUV(vec3(terrainCellCenter.x, terrainCellCenter.y, 0.0));
    float terrainHeight = getZ(terrainUV);
    vec3 terrainNormal = normalize(texture(normalMap, terrainUV).rgb * 2.0 - 1.0);
    vec3 terrainSample = vec3(terrainCellCenter.x, terrainCellCenter.y, terrainHeight);

    return (rayPos.z < zOnPlane(rayPos.xy, terrainSample, terrainNormal));
}

bool debugOcclusionCheck(vec3 rayPos, vec2 terrainCell) {
    
    vec2 terrainUV = toUV(vec3(terrainCell.x, terrainCell.y, 0.0));
    float terrainHeight = getZ(terrainUV);

    return (rayPos.z < terrainHeight);
}


const float PI = 3.14159265359;
const float EPSILON = 0.001;
// Helper function to compute the Fresnel-Schlick approximation

vec3 fresnelSchlick(float cosTheta, vec3 F0) {
    return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
}

// Cook-Torrance BRDF
vec3 cookTorranceBRDF(vec3 normal, vec3 viewDir, vec3 lightDir, float roughness, float metalness, vec3 F0) {
    vec3 H = normalize(viewDir + lightDir);  // Half-vector
    float HdotN = max(dot(H, normal), 0.0);
    float NdotV = max(dot(normal, viewDir), 0.0);
    float NdotL = max(dot(normal, lightDir), 0.0);

    // Roughness term
    float alpha = roughness * roughness;
    float alpha2 = alpha * alpha;

    // Geometry function (Schlick-GGX)
    float G1 = NdotV * (1.0 - alpha) + alpha;
    float G2 = NdotL * (1.0 - alpha) + alpha;
    float G = 1.0 / (G1 * G2);

    // Fresnel-Schlick
    vec3 F = fresnelSchlick(max(dot(H, viewDir), 0.0), F0);

    // Cook-Torrance BRDF equation
    float D = (alpha2 - 1.0) * HdotN * HdotN + 1.0;
    D = alpha2 / (D * D * 3.14159265);

    // Diffuse term (Lambertian)
    vec3 diffuse = (1.0 - F) * (1.0 - metalness) * (1.0 / 3.14159265);

    return (F * D * G) + diffuse;
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
            vec2 tStep;
            vec2 tCurrBound;
            vec2 currCell = fragPos.xy;
            vec2 firstBound = currCell + step;

            if (displacement.x  == 0.0) {
                tStep.x = 1.0;
                tCurrBound.x = 10000.0;
            } else {
                tStep.x = abs(1.0 / displacement.x);
                tCurrBound.x = abs((firstBound.x - fragPos.x) / displacement.x);
            }

            if (displacement.y == 0.0) {
                tStep.y = 1.0;
                tCurrBound.y = 10000.0;
            } else {
                tStep.y = abs(1.0 / displacement.y);
                tCurrBound.y = abs((firstBound.y - fragPos.y) / displacement.y);
            }

            
            float rayFactor = 1.0;

            // t = varys with x
            float t = 0.0;
            vec2 currStep;

            vec3 debugColor = vec3(0.0);
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

                vec3 rayCurrPos = mix(fragPos, lightPos, t);

                // Check exiting current cell
                if (rayOcclusionCheck(rayCurrPos, currCell)) {
                    rayFactor = 0.0;
                    break;
                }

                currCell += currStep;

                // Check entering next cell
                if (rayOcclusionCheck(rayCurrPos, currCell)) {
                    rayFactor = 0.0;
                    break;
                }
            }

            if (rayFactor == 0.0) continue;

            vec3 viewDir = normalize(-v_positionWorld);
            vec3 lightDir = normalize(displacement);


            vec4 albedo = texture(albedoMap, v_uv);
            float roughness = texture(roughnessMap, v_uv).r;
            float metalness = texture(metalnessMap, v_uv).r;
            vec3 F0 = mix(vec3(0.04), albedo.xyz, metalness);

            // Compute PBR shading with Cook-Torrance BRDF
            vec3 specularFactor = cookTorranceBRDF(normal, viewDir, lightDir, roughness, metalness, F0);

            // Lambertian diffuse (not using full PBR reflection here)
            vec3 diffuseFactor = albedo.xyz * max(dot(normal, lightDir), 0.0);

            vec3 lightColor = lightWithDistance(light, length(displacement));


            float rayWeight = 1.0 / float(NUM_RAYS);
            totalLight += rayWeight * normalFactor * (specularFactor + diffuseFactor) * lightColor;

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

    // vec3 absorbedLight = clamp(ambientLighting() + infiniteLighting() + skyLighting() + pointLighting(), 0.0, 1.0);

    // vec4 albedo = texture(albedoMap, v_uv);

    // fragColor = vec4(albedo.rgb * absorbedLight, albedo.a);

    fragColor = vec4(pointLighting(), 1.0);
}