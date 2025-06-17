// #version 300 es
// precision mediump float;

in vec3 v_positionWorld;
in vec3 v_normalWorld; 
in vec2 v_uv;               

uniform sampler2D albedoMap;
uniform sampler2D normalMap;
uniform sampler2D heightMap;

layout(location = 0) out vec4 fragColor0; // Albedo
layout(location = 1) out vec4 fragColor1; // Normals
layout(location = 2) out vec4 fragColor2; // Height

void main() {
    vec4 albedo = texture(albedoMap, v_uv);
    vec4 normal = texture(normalMap, v_uv);
    float height = texture(heightMap, v_uv).r;

    if (albedo.a <= 0.0) discard;

    fragColor0 = albedo;  // Albedo to the first render target
    fragColor1 = normal;  // Normal to the second render target (encoded)
    fragColor2 = vec4(gl_FragCoord.z / -100.0, height, 0.0, 1.0);  // Depth/Height to the third render target
}
