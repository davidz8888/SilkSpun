precision highp float;

in vec3 v_positionWorld;
in vec3 v_viewPositionWorld;
in vec2 v_uv;

uniform float screenWidth;
uniform float screenHeight;

uniform sampler2D hydraulicsMap;
uniform sampler2D emissionsMap;
uniform sampler2D velocityMap;
uniform sampler2D matterMap;

layout(location = 0) out vec4 fragColor0;
layout(location = 1) out vec4 fragColor1;

float NORMALIZATION_FACTOR = 10.0;

float dT = 1.0 / 60.0;

float EPSILON = 0.1; 

float ACCELERATION_SCALING = 1000.0;

vec2 toUV(vec2 worldPos) { 
    return vec2(worldPos.x/screenWidth, worldPos.y/screenHeight) + 0.5;
}

vec2 calculateVelocities() {
    
    vec2 posCenter = v_positionWorld.xy;
    vec2 posLeft = posCenter + vec2(-1.0, 0.0);
    vec2 posDown = posCenter + vec2(0.0, -1.0);

    vec2 UVCenter = toUV(posCenter);
    vec2 UVLeft = toUV(posLeft);
    vec2 UVDown = toUV(posDown);

    vec2 cellVelocity = texture(velocityMap, UVCenter).xy;
    vec2 cellAcceleration = texture(hydraulicsMap, UVCenter).xy;

    float solidityCenter = texture(hydraulicsMap, UVCenter).b;
    float solidityLeft = texture(hydraulicsMap, UVLeft).b;
    float solidityDown = texture(hydraulicsMap, UVDown).b;

    cellVelocity.x = (cellVelocity.x + (cellAcceleration.x * dT * ACCELERATION_SCALING)) * (solidityCenter * solidityLeft);
    cellVelocity.y = (cellVelocity.y + (cellAcceleration.y * dT * ACCELERATION_SCALING)) * (solidityCenter * solidityDown);

    return cellVelocity;
}


vec4 calculateEmissions() {
    
    vec4 matter = texture(matterMap, v_uv);
    vec4 emission = texture(emissionsMap, v_uv);

    matter += emission;

    return matter;
}

void main() {
    
    vec4 velocity = texture(velocityMap, v_uv);
    velocity.xy = calculateVelocities();
    
    fragColor0 = velocity;
    fragColor1 = calculateEmissions();
}
