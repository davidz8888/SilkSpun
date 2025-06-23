// #version 300 es
// precision mediump float;

in vec3 v_positionWorld;
in vec3 v_viewPositionWorld;
in vec2 v_uv;

uniform float screenWidth;
uniform float screenHeight;

uniform sampler2D cellMap; 
uniform sampler2D typeMap;

out vec4 fragColor;

float velocityX
float velocityY

vec2 toUV(vec3 worldPos) { 
    return vec2(worldPos.x/screenWidth, worldPos.y/screenHeight) + 0.5;
}

advectQuantity(float dT) {
    vec2 lastPos = vec2(v_);
}

main() {
    fragColor = 
}
