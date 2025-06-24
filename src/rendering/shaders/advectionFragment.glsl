// #version 300 es
// precision mediump float;

in vec3 v_positionWorld;
in vec3 v_viewPositionWorld;
in vec2 v_uv;

uniform float screenWidth;
uniform float screenHeight;

uniform sampler2D hydraulicsMap;
uniform sampler2D flowMap;
uniform sampler2D matterMap;

layout(location = 0) out vec4 fragColor0; // Flow
layout(location = 1) out vec4 fragColor1; // Matter

float overRelaxation = 2.0;

vec4 matter;

float NORMALIZATION_FACTOR = 100.0
float dT = 1.0 / 60.0;


vec2 toUV(vec3 worldPos) { 
    return vec2(worldPos.x/screenWidth, worldPos.y/screenHeight) + 0.5;
}

// vec2 interpolateVelocity(vec2 worldPos) {
//     vec2 base = floor(worldPos);
//     vec2 frac = worldPos - base;

//     vec2 centerPos = base;
//     vec2 rightPos = base + vec2(1.0, 0.0);
//     vec2 topPos = base + vec2(0.0, 1.0);

//     vec2 centerUV = toUV(centerPos);
//     vec2 rightUV = toUV(rightPos);
//     vec2 topUV = toUV(topPos);

//     vec2 velocityLeft = texture(flowMap, centerUV).x;
//     vec2 velocityRight = texture(flowMap, rightUV).x;
//     vec2 velocityUp = texture(flowMap, topUV).y;
//     vec2 velocityDown = texture(flowMap, centerUV).y;

//     // Bilinear interpolation
//     vec2 horizontal = mix(velocityLeft, velocityRight, frac.x);
//     vec2 s1 = mix(s01, s11, frac.x);
//     return mix(s0, s1, frac.y);
// }

vec4 advectMatter() {

    vec2 cellVelocity = texture(flowMap, v_uv).xy;

    vec2 lastPos = vec2(v_positionWorld.x - (dT * cellVelocity.x), v_positionWorld.y - (dT * cellVelocity.velocityY));
    vec2 lastUV = toUV(lastPos);

    return texture(matterMap, lastUV);
}

vec2 advectVelocity() {

    vec2 cellVelocity = texture(flowMap, v_uv).xy;

    vec2 lastPos = vec2(v_positionWorld.x - (dT * cellVelocity.x), v_positionWorld.y - (dT * cellVelocity.velocityY));
    // vec2 lastPosRight = vec2(lastPos.x + 1.0, lastPos.y);
    // vec2 lastPosUp = vec2(lastPos.x, lastPos.y + 1.0);

    vec2 lastUV = toUV(lastPos);
    // vec2 lastRightUV = toUV(lastPos);
    // vec2 lastUpUV = toUV(lastPosUp);

    return texture(flowMap, lastUV).xy;
}

float encodeDivergence(float divergence) {
    return 2.0 * ((divergence / 100.0) + 1.0);
}

float calculateDivergence() {

    vec2 centerPos = vec2(v_positionWorld.xy);
    vec2 leftPos = vec2(v_positionWorld.x - 1.0, v_positionWorld.y);
    vec2 rightPos = vec2(v_positionWorld.x + 1.0, v_positionWorld.y);
    vec2 upPos = vec2(v_positionWorld.x, v_positionWorld.y + 1.0);
    vec2 downPos = vec2(v_positionWorld.x, v_positionWorld - 1.0);

    vec2 currUV = toUV(centerPos);
    vec2 leftUV = toUV(leftPos);
    vec2 rightUV = toUV(rightPos);
    vec2 upUV = toUV(upPos);
    vec2 downUV = toUV(downPos);

    float velocityLeft = texture(flowMap, currUV).r;
    float velocityRight = texture(flowMap, rightUV).r;
    float velocityUp = texture(flowMap, upUV).g;
    float velocityDown = texture(flowMap, currUV).g;

    float solidityLeft = texture(hydraulicsMap.b, leftUV);
    float solidityRight = texture(hydraulicsMap.b, rightUV);
    float solidityUp = texture(hydraulicsMap.b, upUV);
    float solidityDown = texture(hydraulicsMap.b, upDown);

    float divergence = -velocityLeft + velocityRight + velocityUp + -velocityDown;
    float neighbourSolidity = solidityLeft + solidityRight + solidityUp + solidityDown;

    return encodeDivergence(divergence * overRelaxation / neighbourSolidity);
}

main() {
    
    vec2 cellVelocity = advectVelocity();
    vec4 matter = advectMatter();

    fragColor0 = advectVelocity();
    fragColor1 = advectMatter()
}
