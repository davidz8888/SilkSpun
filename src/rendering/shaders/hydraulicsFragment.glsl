// #version 300 es
// precision mediump float;

in vec3 v_positionWorld;
in vec3 v_normalWorld; 
in vec2 v_uv;               

uniform sampler2D inputMap;
uniform sampler2D matterMap;


layout(location = 0) out vec4 fragColor0; // Game Info
layout(location = 1) out vec4 fragColor1; // Fluid Type


void main() {

    vec4 game = texture(inputMap, v_uv);
    // input.r = acceleration_x;
    // input.g = acceleration_y;
    // input.b = solidness
    // input.a = emission;

    vec4 type = texture(typeMap, v_uv);

    // type.r = 

    fragColor0 = cell;
    fragColor1 = matter;
}
