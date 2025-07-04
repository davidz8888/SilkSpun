precision highp float;

// G-buffer inputs
in vec3 v_positionWorld;
in vec3 v_viewPositionWorld;
in vec2 v_uv;

uniform float screenWidth;
uniform float screenHeight;

uniform sampler2D albedoMap; 
uniform sampler2D normalMap;
uniform sampler2D heightMap;
uniform sampler2D specularMap;
uniform sampler2D shininessMap;

out vec4 fragColor;

// #define NUM_RAYS 47
// const vec3 rayOffsets[NUM_RAYS] = vec3[NUM_RAYS](
//     vec3( 0.000,  0.250,  0.000),
//     vec3( 0.247,  0.243,  0.016),
//     vec3(-0.042,  0.240,  0.246),
//     vec3(-0.222,  0.232, -0.114),
//     vec3( 0.239,  0.222, -0.073),
//     vec3( 0.115,  0.211,  0.209),
//     vec3(-0.229,  0.198,  0.142),
//     vec3(-0.190,  0.184, -0.200),
//     vec3( 0.169,  0.170, -0.217),
//     vec3( 0.205,  0.155,  0.177),
//     vec3(-0.146,  0.139,  0.227),
//     vec3(-0.238,  0.122, -0.091),
//     vec3( 0.233,  0.105, -0.133),
//     vec3( 0.072,  0.088,  0.241),
//     vec3(-0.218,  0.070,  0.170),
//     vec3(-0.177,  0.052, -0.218),
//     vec3( 0.146,  0.034, -0.235),
//     vec3( 0.206,  0.015,  0.170),
//     vec3(-0.106, -0.004,  0.246),
//     vec3(-0.239, -0.024, -0.027),
//     vec3( 0.214, -0.043, -0.179),
//     vec3( 0.095, -0.062,  0.238),
//     vec3(-0.164, -0.081,  0.217),
//     vec3(-0.205, -0.099, -0.152),
//     vec3( 0.112, -0.117, -0.231),
//     vec3( 0.215, -0.135,  0.114),
//     vec3(-0.057, -0.152,  0.240),
//     vec3(-0.233, -0.168,  0.016),
//     vec3( 0.195, -0.185, -0.128),
//     vec3( 0.058, -0.201,  0.223),
//     vec3(-0.149, -0.216,  0.180),
//     vec3(-0.195, -0.231, -0.081),
//     vec3( 0.092, -0.245, -0.184),
//     vec3( 0.188, -0.258,  0.034),
//     vec3(-0.028, -0.271,  0.192),
//     vec3(-0.170, -0.283,  0.093),
//     vec3( 0.068, -0.295, -0.117),
//     vec3( 0.131, -0.306,  0.115),
//     vec3(-0.045, -0.317,  0.095),
//     vec3(-0.109, -0.327, -0.029),
//     vec3( 0.057, -0.336, -0.064),
//     vec3( 0.066, -0.345,  0.038),
//     vec3(-0.031, -0.353,  0.051),
//     vec3(-0.034, -0.361, -0.005),
//     vec3( 0.016, -0.368, -0.014),
//     vec3( 0.005, -0.375,  0.008),
//     vec3( 0.000, -0.381,  0.000)
// );

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

// #define NUM_RAYS 5
// const vec3 rayOffsets[NUM_RAYS] = vec3[NUM_RAYS](
//     vec3(0.0, -0.5, 0.0),
//     vec3(0.0, -0.25, 0.0),
//     vec3(0.0, 0.0, 0.0),
//     vec3(0.0, 0.25, 0.0),
//     vec3(0.0, 0.5, 0.0)
// );

// #define NUM_RAYS 5
// const vec3 rayOffsets[NUM_RAYS] = vec3[NUM_RAYS](
//     vec3(-0.5, 0.0, 0.0),
//     vec3(-0.25, 0.0, 0.0),
//     vec3(0.0, 0.0, 0.0),
//     vec3(0.25, 0.0, 0.0),
//     vec3(0.5, 0.0, 0.0)
// );

// #define NUM_RAYS 4
// const vec3 rayOffsets[NUM_RAYS] = vec3[NUM_RAYS](
//     vec3(-0.25, 0.0, 0.0),
//     vec3(0.25, -0.0, 0.0),
//     vec3(-0.0, -0.25, 0.0),
//     vec3(0.0, 0.25, 0.0)
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

#define MAX_SIMPLELIGHTS 100
uniform PointLight simpleLights[MAX_SIMPLELIGHTS];
uniform int numSimpleLightsInUse;

struct SkyLight {
    vec3 color;
    float shadowDistance;
};
uniform SkyLight skyLight;
#define NUM_SKYLIGHTS 100
uniform vec3 skyLightDirections[NUM_SKYLIGHTS];
int numSkyLightInUse = 50;


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

vec3 decodeNormal(vec2 uv) {

    return normalize(texture(normalMap, uv).rgb * 2.0 - 1.0);
}

vec2 toUV(vec3 worldPos) { 
    return vec2(worldPos.x/screenWidth, worldPos.y/screenHeight) + 0.5;
}


float getZ(vec2 uv) {
    vec4 fragZInfo = texture(heightMap, uv);

    if (fragZInfo.b <= 0.0) {
        return -10000.0;
    } else {
        return fragZInfo.r;
    }

}

float zOnPlane(vec2 xy, vec3 pointOnPlane, vec3 planeNormal) {

    return pointOnPlane.z - (planeNormal.x * (xy.x - pointOnPlane.x) + 
                             planeNormal.y * (xy.y - pointOnPlane.y)) / planeNormal.z;

}

bool reconstructionOcclusionCheck(vec3 rayPos, vec2 terrainCell) {

    vec2 terrainCellCenter = terrainCell += 0.5;
    vec2 terrainUV = toUV(vec3(terrainCellCenter.x, terrainCellCenter.y, 0.0));
    float terrainHeight = getZ(terrainUV);
    vec3 terrainNormal = normalize(texture(normalMap, terrainUV).rgb * 2.0 - 1.0);
    vec3 terrainSample = vec3(terrainCellCenter.x, terrainCellCenter.y, terrainHeight);

    return (rayPos.z < zOnPlane(rayPos.xy, terrainSample, terrainNormal));
}

bool simpleOcclusionCheck(vec3 rayPos, vec2 terrainCell) {
    
    vec2 terrainUV = toUV(vec3(terrainCell.x, terrainCell.y, 0.0));
    float terrainHeight = getZ(terrainUV);

    return (rayPos.z < terrainHeight);
}


vec3 phongSpecular(vec3 specular, float shininess, vec3 lightColor, vec3 lightDir, vec3 normal, vec3 viewDir) {

    vec3 reflectedDir = normalize(reflect(-lightDir, normal));
    const float PI = 3.14159265359;

    float normalizationFactor = (shininess + 2.0) / (2.0 * PI);

    return normalizationFactor * specular * lightColor * pow(max(dot(reflectedDir, viewDir), 0.0), shininess);
}

vec3 phongDiffuse(vec3 albedo, vec3 lightColor, vec3 lightDir, vec3 normal) {

    return albedo * lightColor * max(dot(lightDir, normal), 0.0);
}

vec3 phongColor(vec3 fragPos, vec3 lightDir, vec3 lightColor) {

    vec2 fragUV = toUV(fragPos);
    vec3 albedo = texture(albedoMap, fragUV).rgb;
    vec3 normal = decodeNormal(fragUV);
    vec3 specular = texture(specularMap, fragUV).rgb;
    float shininess = max(texture(shininessMap, fragUV).r * 20.0, 4.0);
    vec3 viewDir = normalize(-fragPos);

    vec3 diffuseComponent = phongDiffuse(albedo, lightColor, lightDir, normal);
    vec3 specularComponent = phongSpecular(specular, shininess, lightColor, lightDir, normal, viewDir);

    return diffuseComponent + specularComponent;
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

vec3 simpleLighting() {

    vec3 totalLight = vec3(0.0);
    float shadowSoftness = 20.0;

    for (int i = 0; i < numSimpleLightsInUse; i++) {
        PointLight light = simpleLights[i];

        for (int j = 0; j < NUM_RAYS; j++) {

            vec3 fragPos = vec3(v_positionWorld.xy, getZ(v_uv));
            vec3 offset = rayOffsets[j] * shadowSoftness;
            vec3 lightPos = light.positionWorld + offset;
            vec3 displacement = lightPos - fragPos;

            if (length(displacement) > light.radius) continue;

            vec3 normal = decodeNormal(v_uv);
            float normalFactor = max(dot(normal, normalize(displacement)), 0.0);
            if (normalFactor == 0.0) continue;

            vec3 lightColor = lightWithDistance(light, length(displacement));
            vec3 color = phongColor(fragPos, normalize(displacement), lightColor);

            float rayWeight = 1.0 / float(NUM_RAYS);
            totalLight += rayWeight * color;
        }
    }

    return totalLight;


}


vec3 pointLighting() {

    vec3 totalLight = vec3(0.0);
    float shadowSoftness = 50.0;

    for (int i = 0; i < numPointLightsInUse; i++) {
        PointLight light = pointLights[i];

        for (int j = 0; j < NUM_RAYS; j++) {

            vec3 fragPos = vec3(v_positionWorld.xy, getZ(v_uv));
            vec3 offset = rayOffsets[j] * shadowSoftness;
            vec3 lightPos = light.positionWorld + offset;
            vec3 displacement = lightPos - fragPos;

            if (length(displacement) > light.radius) continue;

            vec3 normal = decodeNormal(v_uv);
            float normalFactor = max(dot(normal, normalize(displacement)), 0.0);
            if (normalFactor == 0.0) continue;

            if (DDAOcclusionCheck(fragPos, lightPos)) continue;

            vec3 lightColor = lightWithDistance(light, length(displacement));
            vec3 color = phongColor(fragPos, normalize(displacement), lightColor);

            float rayWeight = 1.0 / float(NUM_RAYS);
            totalLight += rayWeight * color;
        }
    }

    return totalLight;
}



vec3 skyLighting() {

    vec3 totalLight = vec3(0);

    for (int i = 0; i < numSkyLightInUse; i++) {

        vec3 fragPos = vec3(v_positionWorld.xy, getZ(v_uv));
        vec3 lightDir = normalize(skyLightDirections[i]);
        
        vec3 normal = normalize(texture(normalMap, v_uv).rgb * 2.0 - 1.0);
        float normalFactor = max((dot(normal, lightDir)), 0.0);
        if (normalFactor == 0.0) continue;

        vec3 lightPos = fragPos + (lightDir * skyLight.shadowDistance);

        if (DDAOcclusionCheck(fragPos, lightPos)) continue;

        vec3 albedo = texture(albedoMap, v_uv).rgb;
        totalLight += (albedo * skyLight.color * normalFactor) / float(numSkyLightInUse);
    }

    return totalLight;
}

vec3 infiniteLighting() {

    vec3 totalLight = vec3(0);

    for (int i = 0; i < numInfiniteLightsInUse; i++) {
        
        InfiniteLight light = infiniteLights[i];

        vec3 fragPos = vec3(v_positionWorld.xy, getZ(v_uv));
        vec3 lightDir = normalize(light.direction);
        
        vec3 normal = normalize(texture(normalMap, v_uv).rgb * 2.0 - 1.0);
        float normalFactor = max((dot(normal, lightDir)), 0.0);
        if (normalFactor == 0.0) continue;

        vec3 lightPos = fragPos + (lightDir * light.shadowDistance);

        // DDA Setup
        if (DDAOcclusionCheck(fragPos, lightPos)) continue;


        vec3 color = phongColor(fragPos, lightDir, light.color);

        // float rayWeight = 1.0 / float(NUM_RAYS);
        float rayWeight = 1.0;
        totalLight += rayWeight * color;
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

    fragColor = vec4(infiniteLighting() + skyLighting() + pointLighting(), 1.0);
    // fragColor = vec4(pointLighting(), 1.0);

    // fragColor = vec4(abs(skyLightDirections[0]), 1.0);
}