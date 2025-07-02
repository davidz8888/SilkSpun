// #version 300 es
// precision mediump float;

in vec3 v_positionWorld;
in vec3 v_normalWorld; 
in vec2 v_uv;       

uniform float heightScaling;

uniform sampler2D albedoMap;
uniform sampler2D normalMap;
uniform sampler2D heightMap;
uniform sampler2D specularMap;
uniform sampler2D shininessMap;
uniform sampler2D hydraulicsMap;
uniform sampler2D emissionsMap;

layout(location = 0) out vec4 fragColor0; // Albedo
layout(location = 1) out vec4 fragColor1; // Normals
layout(location = 2) out vec4 fragColor2; // Height
layout(location = 3) out vec4 fragColor3; // Specular
layout(location = 4) out vec4 fragColor4; // shininess
layout(location = 5) out vec4 fragColor5; // hydraulics
layout(location = 6) out vec4 fragColor6; // emissions


float NORMALIZATION_FACTOR = 1.0;
float EPSILON = 0.1; 


float normalizeInfo(float info) {
    return ((info * 2.0) - 1.0) * NORMALIZATION_FACTOR;
}

float zeroIfClose(float value) {
    return abs(value) < EPSILON ? 0.0 : value;
}

float normalizeSolidity(float solidity) {
    return (solidity - 1.0) * -1.0;
}

void main() {
    vec4 albedo = texture(albedoMap, v_uv);
    if (albedo.a <= 0.0) discard;

    vec4 normal = texture(normalMap, v_uv);
    vec3 heightInfo = texture(heightMap, v_uv).rgb;
    float height = max(max(heightInfo.r, heightInfo.g), heightInfo.b);
    vec4 specular = texture(specularMap, v_uv);
    vec4 shininess = texture(shininessMap, v_uv);
    vec4 hydraulics = texture(hydraulicsMap, v_uv);
    hydraulics.x = zeroIfClose(normalizeInfo(hydraulics.x));
    hydraulics.y = zeroIfClose(normalizeInfo(hydraulics.y));
    hydraulics.b = normalizeSolidity(hydraulics.b);
    vec4 emissions = texture(emissionsMap, v_uv);

    fragColor0 = albedo;
    fragColor1 = normal;
    fragColor2 = vec4(v_positionWorld.z + (height * heightScaling), 0.0, 0.0, 1.0);
    fragColor3 = specular;
    fragColor4 = shininess;
    fragColor5 = hydraulics;
    fragColor6 = emissions;
}
