precision highp float;

in vec3 v_positionWorld;
in vec3 v_normalWorld; 
in vec2 v_uv;               

uniform float screenWidth;
uniform float screenHeight;

uniform sampler2D albedoMap;
uniform sampler2D heightMap;
uniform sampler2D hydraulicsMap;
uniform sampler2D emissionsMap;
uniform sampler2D velocityMap;

uniform vec2 objectVelocity; 
uniform float dragCoefficient;

layout(location = 0) out vec4 fragColor0;
layout(location = 1) out vec4 fragColor1;

float FLUID_Z = -0.0;

float ACCELERATION_SCALING = 100.0;
float EMISSIONS_SCALING = 0.001;

float EPSILON = 0.1; 

vec2 decodeAcceleration(vec2 acceleration) {
    vec2 decodedAcceleration = ((acceleration * 2.0) - 1.0) * ACCELERATION_SCALING;
    // return zeroIfClose(decodedAcceleration);
    return decodedAcceleration;
}

vec2 zeroIfClose(vec2 acceleration) {
    acceleration.x = abs(acceleration.x) < EPSILON ? 0.0 : acceleration.x;
    acceleration.y = abs(acceleration.y) < EPSILON ? 0.0 : acceleration.y;
    return acceleration;
}

float normalizeSolidity(float solidity) {
    return (solidity - 1.0) * -1.0;
}

vec2 toUV(vec2 worldPos) { 
    return vec2(worldPos.x/screenWidth, worldPos.y/screenHeight) + 0.5;
}

float getZ(vec2 uv) {
    vec4 fragZInfo = texture(heightMap, uv);

    // if (fragZInfo.a <= 0.0) {
    //     return -100.0;
    // } else {
    //     return fragZInfo.r;
    // }
    return fragZInfo.r;
}

void main() {

    vec4 albedo = texture(albedoMap, v_uv);
    vec4 hydraulics = texture(hydraulicsMap, v_uv);
    vec4 emissions = texture(emissionsMap, v_uv);


    if (albedo.a <= 0.0 && hydraulics.a <= 0.0 && emissions.a <= 0.0) discard;

    if (hydraulics.a <= 0.0) {
        hydraulics.x = 0.0;
        hydraulics.y = 0.0;
    } else {
        hydraulics.xy = decodeAcceleration(hydraulics.xy);
    }


    hydraulics.b = normalizeSolidity(hydraulics.b);

    // if (albedo.a > 0.0) {
    //     vec2 fluidVelocity = texture(velocityMap, v_uv).xy;
    //     vec2 relativeVelocity = objectVelocity - fluidVelocity;
    //     vec2 dragAcceleration = dragCoefficient * relativeVelocity;
    //     hydraulics.xy += dragAcceleration;
    // }

    float height = getZ(toUV(v_positionWorld.xy));

    if (height > FLUID_Z) {
        hydraulics.b = 0.0;
    }

    fragColor0 = hydraulics;
    fragColor1 = emissions * EMISSIONS_SCALING;
}
