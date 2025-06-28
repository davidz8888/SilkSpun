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

vec2 applyProjection() {

    vec2 posCenter = v_positionWorld.xy;
    vec2 posLeft = posCenter + vec2(-1.0, 0.0);
    vec2 posDown = posCenter + vec2(0.0, -1.0);

    vec2 UVCenter = toUV(posCenter);
    vec2 UVLeft = toUV(posLeft);
    vec2 UVDown = toUV(posDown);

    float solidityCenter = texture(hydraulicsMap, UVCenter).b;
    float solidityLeft = texture(hydraulicsMap, UVLeft).b;
    float solidityDown = texture(hydraulicsMap, UVDown).b;

    vec4 flowCenter = texture(flowMap, UVCenter);
    vec4 flowLeft = texture(flowMap, UVLeft);
    vec4 flowDown = texture(flowMap, UVDown);

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

    vec4 flow = texture(flowMap, v_uv);
    flow.xy = applyProjection();
    vec4 matter = texture(matterMap, v_uv);

    fragColor0 = flow;
    fragColor1 = matter;
}