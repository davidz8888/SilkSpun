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
float overRelaxation = 2.0;

vec4 matter;

vec2 toUV(vec3 worldPos) { 
    return vec2(worldPos.x/screenWidth, worldPos.y/screenHeight) + 0.5;
}

float normalizeDivergence(float divergence) {
    return ((divergence * 2.0) - 1.0) * NORMALIZATION_FACTOR;
}

vec2 applyProjection() {

    vec2 centerPos = vec2(v_positionWorld.x, v_positionWorld.y);
    vec2 leftPos = vec2(centerPos.x - 1.0, centerPos.y);
    vec2 rightPos = vec2(centerPos.x + 1.0, centerPos.y);
    vec2 upPos = vec2(centerPos.x, centerPos.y + 1.0);
    vec2 downPos = vec2(centerPos.x, centerPos.y - 1.0);

    vec2 centerUV = toUV(centerPos);
    vec2 leftUV = toUV(leftPos);
    vec2 rightUV = toUV(rightPos);
    vec2 upUV = toUV(upPos);
    vec2 downUV = toUV(downPos);

    vec4 flowCenter = texture(flowMap, centerUV);
    vec4 flowLeft = texture(flowMap, leftUV);
    vec4 flowRight = texture(flowMap, rightUV);
    vec4 flowUp = texture(flowMap, upUV);
    vec4 flowDown = texture(flowMap, downUV);

    float solidityLeft = texture(hydraulicsMap, leftUV).b;
    float solidityRight = texture(hydraulicsMap, rightUV).b;
    float solidityUp = texture(hydraulicsMap, upUV).b;
    float solidityDown = texture(hydraulicsMap, downUV).b;

    float divergenceCenter = normalizeDivergence(flowCenter.b);
    float divergenceLeft = normalizeDivergence(flowLeft.b);
    float divergenceRight = normalizeDivergence(flowRight.b);
    float divergenceUp = normalizeDivergence(flowUp.b);
    float divergenceDown = normalizeDivergence(flowDown.b);

    // Each cell stores only its left and down velocities to avoid doubling
    float velocityLeft = flowCenter.r;
    float velocityRight = flowRight.r;
    float velocityUp = flowUp.g;
    float velocityDown = flowCenter.g;

    velocityLeft += (divergenceCenter - divergenceLeft) * solidityLeft;
    velocityDown += (divergenceCenter - divergenceDown) * solidiyDown;

    return vec2(velocityLeft, velocityDown);
}

void main() {
    vec2 cellVelocity = applyProjection();
    vec4 matter = texture(matterMap, v_uv);

    fragColor0 = vec4(cellVelocity.x, cellVelocity.y, 0.0, 0.0);
    // fragColor1 = matter;
    fragColor1 = vec4(1.0);
}