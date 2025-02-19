// #version 300 es
// precision mediump float;

in vec3 v_positionWorld;    // World position of the vertex
in vec3 v_normalWorld;      // Normal in world space
in vec2 v_uv;               // Texture coordinates

uniform sampler2D albedoMap;
uniform sampler2D normalMap;
uniform sampler2D heightMap;

layout(location = 0) out vec4 fragColor0; // Albedo (e.g., color)
layout(location = 1) out vec4 fragColor1; // Normals
layout(location = 2) out vec4 fragColor2; // Height


float toSigmoid(float x) {
    return 1.0 / (1.0 + exp(-x));
}

void main() {
    vec4 albedo = texture(albedoMap, v_uv);
    vec3 normal = texture(normalMap, v_uv).rgb;
    float height = texture(heightMap, v_uv).r;

    if (albedo.a <= 0.0) {
        discard;
    }
    // Output the results to different render targets
    fragColor0 = albedo;  // Albedo to the first render target
    fragColor1 = vec4(normal * 2.0 - 1.0, 1.0);  // Normal to the second render target (encoded)
    fragColor2 = vec4(toSigmoid(v_positionWorld.z), height, 0.0, 1.0);  // Depth/Height to the third render target
}
