// #version 300 es
// precision mediump float;

in vec3 v_positionWorld;
in vec3 v_normalWorld; 
in vec2 v_uv;               

uniform sampler2D albedoMap;
uniform sampler2D normalMap;
uniform sampler2D heightMap;
uniform sampler2D roughnessMap;
uniform sampler2D metalnessMap;

layout(location = 0) out vec4 fragColor0; // Albedo
layout(location = 1) out vec4 fragColor1; // Normals
layout(location = 2) out vec4 fragColor2; // Height
layout(location = 3) out vec4 fragColor3; // Roughness
layout(location = 4) out vec4 fragColor4; // Metalness

void main() {
    vec4 albedo = texture(albedoMap, v_uv);
    if (albedo.a <= 0.0) discard;

    vec4 normal = texture(normalMap, v_uv);
    float height = texture(heightMap, v_uv).r;
    vec4 roughness = texture(roughnessMap, v_uv);
    vec4 metalness = texture(metalnessMap, v_uv);


    fragColor0 = albedo;
    fragColor1 = normal;
    fragColor2 = vec4(v_positionWorld.z / -100.0, height, 1.0, 1.0);  // Depth/Height to the third render target
    fragColor3 = roughness;
    fragColor4 = metalness;
}
