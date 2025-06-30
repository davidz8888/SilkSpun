precision highp float;

in vec3 v_positionWorld;
in vec3 v_normalWorld;
in vec2 v_uv;

uniform float screenWidth;
uniform float screenHeight;

uniform sampler2D albedoMap; 
uniform sampler2D normalMap;

out vec4 fragColor;

struct SkyLight {
    vec3 color;
    float shadowDistance;
};
#define NUM_SKYLIGHTS 6
uniform SkyLight skyLight;
const vec3 skyLightDirections[NUM_SKYLIGHTS] = vec3[NUM_SKYLIGHTS](
    vec3(0.0, 1.0, 0.0),
    vec3(1.0, 1.0, 0.0),
    vec3(-1.0, 1.0, 0.0),
    vec3(0.0, 1.0, 1.0),
    vec3(0.333, 1.0, 0.333),
    vec3(-0.333, 1.0, 0.333)
);


struct InfiniteLight {
    vec3 direction;
    vec3 color;
    float shadowDistance;
};
#define NUM_INFINITELIGHTS 2
uniform InfiniteLight infiniteLights[NUM_INFINITELIGHTS];

vec3 skyLighting() {

    vec3 totalLight = vec3(0);

    for (int i = 0; i < NUM_SKYLIGHTS; i++) {

        vec3 lightDirection = skyLightDirections[i];

        vec3 normal = normalize(texture(normalMap, v_uv).rgb * 2.0 - 1.0);
        float normalFactor = max((dot(normal, normalize(lightDirection))), 0.0);

        totalLight += (normalFactor * skyLight.color);

    }

    return totalLight / float(NUM_SKYLIGHTS);
}

vec3 infiniteLighting() {
    
    vec3 totalLight = vec3(0);

    for (int i = 0; i < NUM_INFINITELIGHTS; i++) {

        InfiniteLight light = infiniteLights[i];
        vec3 lightDirection = light.direction;

        vec3 normal = normalize(texture(normalMap, v_uv).rgb * 2.0 - 1.0);
        float normalFactor = max((dot(normal, normalize(lightDirection))), 0.0);

        totalLight += (normalFactor * light.color);

    }

    return totalLight;
}

vec3 ambientLighting() {
    return vec3(0);
}


void main() {

    vec4 albedo = texture(albedoMap, v_uv);

    if (albedo.a == 0.0) discard;

    vec3 absorbedLight = clamp(skyLighting() + infiniteLighting(), 0.0, 1.0);

    fragColor = vec4(albedo.rgb * absorbedLight, albedo.a);
}