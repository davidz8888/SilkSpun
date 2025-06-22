// #version 300 es
// precision mediump float;

in vec3 v_positionWorld;
in vec3 v_normalWorld; 
in vec2 v_uv;               

uniform sampler2D cellMap;
uniform sampler2D typeMap;


layout(location = 0) out vec4 fragColor0; // Cell Info
layout(location = 1) out vec4 fragColor1; // Fluid Type


void main() {
    vec4 cell = texture(cellMap, v_uv);
    vec4 type = texture(typeMap, v_uv);

    fragColor0 = cell;
    fragColor1 = type;
}
