// #version 300 es
// precision mediump float;

in vec3 v_positionWorld;
in vec3 v_normalWorld; 
in vec2 v_uv;               

uniform sampler2D albedoMap;
uniform sampler2D normalMap;
uniform sampler2D heightMap;
uniform sampler2D specularMap;
uniform sampler2D shininessMap;
uniform sampler2D hydraulicsMap;

layout(location = 0) out vec4 fragColor0; // Albedo
layout(location = 1) out vec4 fragColor1; // Normals
layout(location = 2) out vec4 fragColor2; // Height
layout(location = 3) out vec4 fragColor3; // Specular
layout(location = 4) out vec4 fragColor4; // shininess
layout(location = 5) out vec4 fragColor5; // hydraulics

void main() {
    vec4 albedo = texture(albedoMap, v_uv);
    if (albedo.a <= 0.0) discard;

    vec4 normal = texture(normalMap, v_uv);
    float height = texture(heightMap, v_uv).r;
    vec4 specular = texture(specularMap, v_uv);
    vec4 shininess = texture(shininessMap, v_uv);
    vec4 hydraulics = texture(hydraulicsMap, v_uv);

    fragColor0 = albedo;
    fragColor1 = normal;
    fragColor2 = vec4(v_positionWorld.z / -100.0, height, 1.0, 1.0);  // Depth/Height to the third render target
    fragColor3 = specular;
    fragColor4 = shininess;
    fragColor5 = hydraulics;
    
}
