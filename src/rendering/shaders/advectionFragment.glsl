precision highp float;

in highp vec3 v_positionWorld;
in vec3 v_viewPositionWorld;
in highp vec2 v_uv;

uniform float screenWidth;
uniform float screenHeight;

uniform sampler2D hydraulicsMap;
uniform highp sampler2D velocityMap;
uniform highp sampler2D matterMap;

layout(location = 0) out vec4 fragColor0;
layout(location = 1) out vec4 fragColor1;

float dT = 1.0 / 60.0;



vec2 toUV(vec2 worldPos) { 
    return vec2(worldPos.x/screenWidth, worldPos.y/screenHeight) + 0.5;
}


vec4 interpolatingSample(sampler2D map, vec2 worldPos) {

    float bias = 0.5;
    worldPos -= vec2(0.5, 0.5);
    vec2 base = floor(worldPos);
    vec2 offset = worldPos - base;
    vec2 complement = 1.0 - offset;

    vec2 bottomLeftPos = base + vec2(bias, bias);
    vec2 bottomRightPos = bottomLeftPos + vec2(1.0, 0.0);
    vec2 topLeftPos = bottomLeftPos + vec2(0.0, 1.0);
    vec2 topRightPos = bottomLeftPos + vec2(1.0, 1.0);

    vec2 bottomLeftUV = toUV(bottomLeftPos);
    vec2 bottomRightUV = toUV(bottomRightPos);
    vec2 topLeftUV = toUV(topLeftPos);
    vec2 topRightUV = toUV(topRightPos);

    // float texelX = 1.0 / screenWidth;
    // float texelY = 1.0 / screenHeight;

    // vec2 bottomLeftUV = v_uv;
    // vec2 bottomRightUV = v_uv + vec2(texelX, 0.0);
    // vec2 topLeftUV = v_uv + vec2(0.0, texelY);
    // vec2 topRightUV = v_uv + vec2(texelX, texelY);

    vec4 bottomLeftValue = texture(map, bottomLeftUV) * (complement.x * complement.y);
    vec4 bottomRightValue = texture(map, bottomRightUV) * (offset.x * complement.y);
    vec4 topLeftValue = texture(map, topLeftUV) * (complement.x * offset.y);
    vec4 topRightValue = texture(map, topRightUV) * (offset.x * offset.y);
    

    // return topLeftValue;
    return (bottomLeftValue + bottomRightValue + topLeftValue + topRightValue);
    // return texture(map, toUV(worldPos));

    // float oneDifference = 1.0 - ((complement.x * complement.y) + (offset.x * complement.y) + (complement.x + offset.y) + (offset.x * offset.y));

    // return vec4(oneDifference);
    // return vec4(1.0, 1.0, 0.0, 1.0); 
}



vec2 backstep() {

    vec2 cellVelocity = interpolatingSample(velocityMap, v_positionWorld.xy).xy; 
    return v_positionWorld.xy - (cellVelocity * dT);
}


void main() {

    vec4 velocity;
    vec4 matter;

    if (texture(hydraulicsMap, v_uv).b == 0.0) {

        velocity = vec4(0.0, 0.0, 0.0, 0.0);
        matter = vec4(0.0, 0.0, 0.0, 0.0);

    } else {

        vec2 lastPos = backstep();

        velocity = interpolatingSample(velocityMap, lastPos);
        matter = interpolatingSample(matterMap, lastPos);
        // matter = texture(matterMap, toUV(lastPos));
    }

    // fragColor0 = texture(velocityMap, v_uv);
    fragColor0 = vec4(velocity.x, velocity.y, 0.0, 1.0);
    fragColor1 = matter;


}
