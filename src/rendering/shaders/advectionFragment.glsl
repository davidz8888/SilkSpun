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

float OVER_RELAXATION = 2.0;

vec4 matter;

float NORMALIZATION_FACTOR = 1.0;
float dT = 1.0 / 60.0;


vec2 toUV(vec2 worldPos) { 
    return vec2(worldPos.x/screenWidth, worldPos.y/screenHeight) + 0.5;
}


float normalizeInfo(float info) {
    return ((info * 2.0) - 1.0) * NORMALIZATION_FACTOR;
}

float encodeInfo(float info) {
    return ((info / NORMALIZATION_FACTOR) + 1.0) / 2.0;
}

float normalizeSolidity(float solidity) {
    return (solidity - 1.0) * -1.0;
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


    float lastX = v_positionWorld.x - (dT * cellVelocity.x * OVER_RELAXATION);
    float lastY = v_positionWorld.y - (dT * cellVelocity.y * OVER_RELAXATION);
    vec2 lastPos = vec2(lastX, lastY);

    vec2 lastUV = toUV(lastPos);

    return texture(matterMap, lastUV);
}

vec2 advectVelocity() {

    vec2 cellVelocity = texture(flowMap, v_uv).xy; 


    float lastX = v_positionWorld.x - (dT * cellVelocity.x * OVER_RELAXATION);
    float lastY = v_positionWorld.y - (dT * cellVelocity.y * OVER_RELAXATION);
    vec2 lastPos = vec2(lastX, lastY);

    vec2 lastUV = toUV(lastPos);

    return texture(flowMap, lastUV).xy;
}

vec2 debugVelocity() {
    return vec2(0.0);
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

    float solidityLeft = normalizeSolidity(texture(hydraulicsMap, leftUV).b);
    float solidityRight = normalizeSolidity(texture(hydraulicsMap, rightUV).b);
    float solidityUp = normalizeSolidity(texture(hydraulicsMap, upUV).b);
    float solidityDown = normalizeSolidity(texture(hydraulicsMap, downUV).b);

    float divergence = -velocityLeft + velocityRight + velocityUp + -velocityDown;
    float neighbourSolidity = solidityLeft + solidityRight + solidityUp + solidityDown;

    return divergence * OVER_RELAXATION / neighbourSolidity;
}

void main() {

    // if (texture(hydraulicsMap, v_uv).b == 1.0) {
    //     fragColor0 = vec4(0.0);
    //     fragColor1 = vec4(0.0);
    // }
    
    // vec2 cellVelocity = advectVelocity();
    // vec2 cellVelocity = debugVelocity();

    float divergence = calculateDivergence();
    vec4 flow = texture(flowMap, v_uv);

    vec4 matter = advectMatter();

    // fragColor0 = vec4(cellVelocity.x, cellVelocity.y, divergence, flow.a);
    fragColor1 = matter;

    fragColor0 = texture(flowMap, v_uv);
    // fragColor1 = texture(matterMap, v_uv);
}
