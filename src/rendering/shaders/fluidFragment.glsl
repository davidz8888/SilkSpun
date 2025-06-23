// #version 300 es
// precision mediump float;

in vec3 v_positionWorld;
in vec3 v_viewPositionWorld;
in vec2 v_uv;

uniform float screenWidth;
uniform float screenHeight;

uniform sampler2D cellMap;
uniform sampler2D hydraulicsMap;
uniform sampler2D matterMap;

out vec4 fragColor;

float velocityX
float velocityY

vec2 toUV(vec3 worldPos) { 
    return vec2(worldPos.x/screenWidth, worldPos.y/screenHeight) + 0.5;
}

advectMatter(float dT) {
    vec2 lastPos = vec2(v_positionWorld.x - (dT * velocityX), v_positionWOrld.y - (dT * velocityY));
    vec2 lastUV = toUV(lastPos);
    
    return texture(matterMap, lastUV);
}

main() {
    fragColor = advectMatter();
}
