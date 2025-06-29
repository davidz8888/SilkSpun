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


vec4 interpolatingSample(sampler2D map, vec2 worldPos) {

    vec2 base = floor(worldPos);
    vec2 offset = worldPos - base;
    vec2 complement = 1.0 - offset;

    vec2 bottomLeftPos = base;
    vec2 bottomRightPos = base + vec2(1.0, 0.0);
    vec2 topLeftPos = base + vec2(0.0, 1.0);
    vec2 topRightPos = base + vec2(1.0, 1.0);

    vec2 bottomLeftUV = toUV(bottomLeftPos);
    vec2 bottomRightUV = toUV(bottomRightPos);
    vec2 topLeftUV = toUV(topLeftPos);
    vec2 topRightUV = toUV(topRightPos);

    vec4 bottomLeftValue = texture(map, bottomLeftUV) * complement.x * complement.y;
    vec4 bottomRightValue = texture(map, bottomRightUV) * offset.x * complement.y;
    vec4 topLeftValue = texture(map, topLeftUV) * complement.x * offset.y;
    vec4 topRightValue = texture(map, topRightUV) * offset.x * offset.y;
    
    return bottomLeftValue + bottomRightValue + topLeftValue + topRightValue;
}


vec2 backstep() {

    vec2 cellVelocity = texture(flowMap, v_uv).xy; 
    return floor(v_positionWorld.xy) - (cellVelocity * dT);
    return v_positionWorld.xy - (cellVelocity * dT);

}


void main() {

    vec4 flow;
    vec4 matter;

    if (texture(hydraulicsMap, v_uv).b == 0.0) {

        flow = vec4(0.0, 0.0, 0.0, 1.0);
        matter = vec4(0.0, 0.0, 0.0, 0.0);

    } else {

    vec2 lastPos = backstep();

    flow = interpolatingSample(flowMap, lastPos);
    matter = interpolatingSample(matterMap, lastPos);
    }

    // vec2 lastPos = backstep();

    // vec4 flow = interpolatingSample(flowMap, lastPos);
    // vec4 matter = interpolatingSample(matterMap, lastPos);

    fragColor0 = flow;
    fragColor1 = matter;
}
