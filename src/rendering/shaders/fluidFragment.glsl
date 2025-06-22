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

float v_up;
float v_down;


main() {
    fragColor = 
}
