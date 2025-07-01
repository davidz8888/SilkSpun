precision highp float;

in vec3 v_positionWorld;
in vec3 v_viewPositionWorld;
in vec2 v_uv;

uniform float screenWidth;
uniform float screenHeight;

uniform sampler2D hydraulicsMap;
uniform sampler2D velocityMap;
uniform sampler2D matterMap;
uniform sampler2D pressureMap;
uniform sampler2D divergenceMap;

layout(location = 0) out vec4 fragColor0;
layout(location = 1) out vec4 fragColor1;

float OVER_RELAXATION = 0.5;

vec2 toUV(vec2 worldPos) { 
    return vec2(worldPos.x/screenWidth, worldPos.y/screenHeight) + 0.5;
}

vec4 applyProjection() {

    vec2 posCenter = v_positionWorld.xy;
    vec2 posLeft = posCenter + vec2(-1.0, 0.0);
    vec2 posDown = posCenter + vec2(0.0, -1.0);

    // vec2 UVCenter = toUV(posCenter);
    // vec2 UVLeft = toUV(posLeft);
    // vec2 UVDown = toUV(posDown);

    float texelX = 1.0 / screenWidth;
    float texelY = 1.0 / screenHeight;

    vec2 UVCenter = v_uv;
    vec2 UVLeft = v_uv + vec2(-texelX, 0.0);
    vec2 UVDown = v_uv + vec2(0.0, -texelY);

    float solidityCenter = texture(hydraulicsMap, UVCenter).b;
    float solidityLeft = texture(hydraulicsMap, UVLeft).b;
    float solidityDown = texture(hydraulicsMap, UVDown).b;

    float pressureCenter = texture(pressureMap, UVCenter).r;
    float pressureLeft = texture(pressureMap, UVLeft).r;
    float pressureDown = texture(pressureMap, UVDown).r;

    // Each cell stores only its left and down velocities to avoid doubling

    vec4 velocity = texture(velocityMap, UVCenter);

    velocity.x -= (pressureCenter - pressureLeft) * (solidityCenter * solidityLeft);
    velocity.y -= (pressureCenter - pressureDown) * (solidityCenter * solidityDown);

    return velocity;

    // float divergenceCenter = texture(divergenceMap, UVCenter).r;
    // float divergenceLeft = texture(divergenceMap, UVLeft).r;
    // float divergenceDown = texture(divergenceMap, UVDown).r;

    // velocity.x += (divergenceCenter - divergenceLeft) * OVER_RELAXATION * (solidityCenter * solidityLeft) / 2.0;
    // velocity.y += (divergenceCenter - divergenceDown) * OVER_RELAXATION * (solidityCenter * solidityDown) / 2.0;

    // return velocity;
}

void main() {

    vec4 velocity = applyProjection();
    // vec4 velocity = texture(velocityMap, v_uv);
    vec4 matter = texture(matterMap, v_uv);

    fragColor0 = velocity;
    fragColor1 = matter;
}