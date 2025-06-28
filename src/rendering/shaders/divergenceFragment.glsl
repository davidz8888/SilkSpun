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

float OVER_RELAXATION = 2.0;
float dT = 1.0 / 60.0;


vec2 toUV(vec2 worldPos) { 
    return vec2(worldPos.x/screenWidth, worldPos.y/screenHeight) + 0.5;
}

float calculateDivergence() {

    vec2 posCenter = v_positionWorld.xy;
    vec2 posLeft = posCenter + vec2(-1.0, 0.0);
    vec2 posRight = posCenter + vec2(1.0, 0.0);
    vec2 posUp = posCenter + vec2(0.0, 1.0);
    vec2 posDown = posCenter + vec2(0.0, -1.0);

    vec2 UVCenter = toUV(posCenter);
    vec2 UVLeft = toUV(posLeft);
    vec2 UVRight = toUV(posRight);
    vec2 UVUp = toUV(posUp);
    vec2 UVDown = toUV(posDown);

    float velocityLeft = texture(flowMap, UVCenter).r;
    float velocityRight = texture(flowMap, UVRight).r;
    float velocityUp = texture(flowMap, UVUp).g;
    float velocityDown = texture(flowMap, UVCenter).g;

    float solidityLeft = texture(hydraulicsMap, UVLeft).b;
    float solidityRight = texture(hydraulicsMap, UVRight).b;
    float solidityUp = texture(hydraulicsMap, UVUp).b;
    float solidityDown = texture(hydraulicsMap, UVDown).b;

    float divergence = -velocityLeft + velocityRight + velocityUp + -velocityDown;
    float neighbourSolidity = solidityLeft + solidityRight + solidityUp + solidityDown;

    float result = neighbourSolidity != 0.0 ? (divergence / neighbourSolidity) : 0.0;
    return result;
}

void main() {

    vec4 flow = texture(flowMap, v_uv);
    flow.b = calculateDivergence();
    vec4 matter = texture(matterMap, v_uv);    

    fragColor0 = flow;
    fragColor1 = matter;
}
