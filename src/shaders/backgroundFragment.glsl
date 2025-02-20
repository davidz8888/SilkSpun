// #version 300 es
// precision mediump float;

// G-buffer inputs
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
};

struct InfiniteLight {
    vec3 direction;
    vec3 color;
};

const float HEIGHT_SCALING = 2.0;
#define NUM_POINTLIGHTS 4
#define NUM_SKYLIGHTS 6

const vec3 skyLightDirections[NUM_SKYLIGHTS] = vec3[NUM_SKYLIGHTS](
    vec3(0.0, 1.0, 0.0),
    vec3(1.0, 1.0, 0.0),
    vec3(-1.0, 1.0, 0.0),
    vec3(0.0, 1.0, 1.0),
    vec3(0.333, 1.0, 0.333),
    vec3(-0.333, 1.0, 0.333)
);

uniform PointLight pointLights[NUM_POINTLIGHTS];
uniform SkyLight skyLight;
uniform InfiniteLight infiniteLight;



vec3 skyLighting() {

    vec3 totalLight = vec3(0);

    for (int i = 0; i < NUM_SKYLIGHTS; i++) {


        vec3 lightDirection = skyLightDirections[i];

        vec3 normal = texture(normalMap, v_uv).rgb;
        float normalFactor = max((dot(normal, lightDirection)), 0.0);

        totalLight += (normalFactor * skyLight.color);
    }

    // return skyLight.color;
    return totalLight / float(NUM_SKYLIGHTS);
}

vec3 infiniteLighting() {
    return texture(heightMap, v_uv).g * ambientLight;
}

vec3 ambientLighting() {
    return ambientLight;
}


void main() {

    // vec3 absorbedLight = pointLighting() + ambientLighting();
    vec3 absorbedLight = pointLighting() + ambientLighting();

    fragColor = vec4(texture(albedoMap, v_uv).rgb * absorbedLight, 1.0);

}