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
uniform sampler2D heightMap;

out vec4 fragColor;

struct PointLight {
    vec3 positionWorld;
    vec3 color;
    float falloff;
    float radius;
};

struct PlaneLight {
    float z;
    vec3 color;
    vec3 stepDirection;
};

uniform PointLight pointLights[10];
uniform PlaneLight planeLights[3];

struct Light {
    vec3 positionWorld;
    vec3 color;
    float falloff;
    float radius;
};

// // Uniform block containing the array of structs
// layout(std140) uniform lightBuffer {
//     Light lights[10];  // Array of structs with a max size of 10
// }; 
 
 
// const Light light0 = Light(vec3(100.0, 0.0, 20.0), vec3(1.0, 0.8, 0.0), 0.2, 300.0);
// const Light light1 = Light(vec3(-100.0, 0.0, 20.0), vec3(0.0, 1.0, 0.0), 0.2, 300.0);
const vec3 ambientLight = vec3(0.0, 0.025, 0.05);
// const Light lights[2] = {light0, light1};

const Light lights[9] = Light[](
    Light(vec3(100.0, 0.0, 20.0), vec3(1.0, 0.0, 0.0), 0.2, 300.0),
    Light(vec3(-100.0, 0.0, 20.0), vec3(0.0, 1.0, 0.0), 0.2, 300.0),
    Light(vec3(0.0, 500.0, 20.0), vec3(0.0, 0.0, 1.0), 0.2, 300.0),
    Light(vec3(100.0, 0.0, 20.0), vec3(1.0, 0.0, 0.0), 0.2, 300.0),
    Light(vec3(-100.0, 0.0, 20.0), vec3(0.0, 1.0, 0.0), 0.2, 300.0),
    Light(vec3(0.0, 500.0, 20.0), vec3(0.0, 0.0, 1.0), 0.2, 300.0),
    Light(vec3(100.0, 0.0, 20.0), vec3(1.0, 0.0, 0.0), 0.2, 300.0),
    Light(vec3(-100.0, 0.0, 20.0), vec3(0.0, 1.0, 0.0), 0.2, 300.0),
    Light(vec3(0.0, 500.0, 20.0), vec3(0.0, 0.0, 1.0), 0.2, 300.0)
);

vec3 lightWithDistance(Light light, float distance) {
    return light.color * ((light.radius - distance) / ((light.falloff * distance * distance) + light.radius));

}

bool locationEquality(vec3 posA, vec3 posB, float epsilon) {
    return length(posA - posB) < epsilon;
}

vec2 toUV(vec3 worldPos) { 
    return vec2(worldPos.x/screenWidth, worldPos.y/screenHeight) + 0.5;
}


float inverseSigmoid(float y) {
    return log(y / (1.0 - y));
}

vec3 toUnitCube(vec3 v) {
    return v / max(abs(v.x), abs(v.y));
}

vec3 directionalLight() {

    vec3 totalLight = vec3(0);

    for (int i = 0; i < 9; i++) {

        Light light = lights[i];

        vec4 heightStuff = texture(heightMap, v_uv);
        vec3 fragPosition = vec3(v_positionWorld.xy, inverseSigmoid(heightStuff.r) + heightStuff.g * 2.0);
        vec3 displacement = light.positionWorld - fragPosition;
        vec3 rayStep = toUnitCube(displacement);

        float lightFactor = step(length(displacement) - light.radius, 0.0);

        vec3 rayPosition = fragPosition; 
        
        for (float i = 0.0; i < length(displacement.xy); i += 1.0 * length(rayStep.xy)) {
            
            rayPosition += 1.0 * rayStep;
            vec4 zInfo = texture(heightMap, toUV(rayPosition));
            // bool occluded = ((inverseSigmoid(zInfo.r)) + (zInfo.g * 2.0) > rayPosition.z);
            // lightFactor *= (occluded ? 0.0 : 1.0); 
            lightFactor = min(max(rayPosition.z + 1.0 - ((inverseSigmoid(zInfo.r)) + (zInfo.g * 2.0)), 0.0), lightFactor); 

            if (int(lightFactor) == 0) break;

        }

        vec3 normal = texture(normalMap, v_uv).rgb ;
        totalLight += (lightFactor * max((dot(normal, normalize(displacement))), 0.0) * lightWithDistance(light, length(displacement)));
    }

    return totalLight;
}

vec3 ambientLighting() {
    return texture(heightMap, v_uv).g * ambientLight;
}



void main() {

    vec3 absorbedLight = directionalLight() + ambientLighting();
    fragColor = vec4(texture(albedoMap, v_uv).rgb * absorbedLight, 1.0);

}