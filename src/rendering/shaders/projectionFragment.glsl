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

float NORMALIZATION_FACTOR = 1.0;

vec4 matter;

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

vec2 applyProjection() {

    vec2 centerPos = vec2(v_positionWorld.x, v_positionWorld.y);
    vec2 leftPos = vec2(centerPos.x - 1.0, centerPos.y);
    vec2 downPos = vec2(centerPos.x, centerPos.y - 1.0);

    vec2 centerUV = toUV(centerPos);
    vec2 leftUV = toUV(leftPos);
    vec2 downUV = toUV(downPos);

    vec4 flowCenter = texture(flowMap, centerUV);
    vec4 flowLeft = texture(flowMap, leftUV);
    vec4 flowDown = texture(flowMap, downUV);

    float solidityCenter = normalizeSolidity(texture(hydraulicsMap, centerUV).b);
    float solidityLeft = normalizeSolidity(texture(hydraulicsMap, leftUV).b);
    float solidityDown = normalizeSolidity(texture(hydraulicsMap, downUV).b);

    float divergenceCenter = flowCenter.b;
    float divergenceLeft = flowLeft.b;
    float divergenceDown = flowDown.b;

    // Each cell stores only its left and down velocities to avoid doubling
    float velocityLeft = flowCenter.r;
    float velocityDown = flowCenter.g;

    velocityLeft += (divergenceCenter - divergenceLeft) * (solidityCenter * solidityLeft);
    velocityDown += (divergenceCenter - divergenceDown) * (solidityCenter * solidityDown);

    return vec2(velocityLeft, velocityDown);
}

void main() {

    if (texture(hydraulicsMap, v_uv).b == 1.0) {
        discard;
    }
    
    vec4 flow = texture(flowMap, v_uv);
    vec2 cellVelocity = applyProjection();
    vec4 matter = texture(matterMap, v_uv);

    fragColor0 = vec4(cellVelocity.x, cellVelocity.y, flow.b, flow.a);
    fragColor1 = matter;
}