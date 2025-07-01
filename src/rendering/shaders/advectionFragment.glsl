precision highp float;

in highp vec3 v_positionWorld;
in vec3 v_viewPositionWorld;
in vec2 v_uv;

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

    worldPos -= vec2(0.5, 0.5);
    vec2 base = floor(worldPos);
    vec2 offset = worldPos - base;
    vec2 complement = 1.0 - offset;

    vec2 bottomLeftPos = base;
    vec2 bottomRightPos = base + vec2(1.0, 0.0);
    vec2 topLeftPos = base + vec2(0.0, 1.0);
    vec2 topRightPos = base + vec2(1.0, 1.0);

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

    vec4 bottomLeftValue = texture(map, bottomLeftUV) * complement.x * complement.y;
    vec4 bottomRightValue = texture(map, bottomRightUV) * offset.x * complement.y;
    vec4 topLeftValue = texture(map, topLeftUV) * complement.x * offset.y;
    vec4 topRightValue = texture(map, topRightUV) * offset.x * offset.y;
    
    return bottomLeftValue + bottomRightValue + topLeftValue + topRightValue;
    // return texture(map, v_uv);

}


float interpolateVelocityX(vec2 worldPos) {

    vec2 base = floor(worldPos - vec2(0.5, 0.5));
    vec2 frac = worldPos - base - vec2(0.5, 0.5);
    vec2 complement = 1.0 - frac;

    vec2 posBottomLeft = base;
    vec2 posBottomRight = base + vec2(1.0, 0.0);
    vec2 posTopLeft = base + vec2(0.0, 1.0);
    vec2 posTopRight = base + vec2(1.0, 1.0);

    vec2 UVBottomLeft = toUV(posBottomLeft);
    vec2 UVBottomRight = toUV(posBottomRight);
    vec2 UVTopLeft = toUV(posTopLeft);
    vec2 UVTopRight = toUV(posTopRight);

    float velocityBottomLeft = texture(velocityMap, UVBottomLeft).x;
    float velocityBottomRight = texture(velocityMap, UVBottomRight).x;
    float velocityTopLeft = texture(velocityMap, UVTopLeft).x;
    float velocityTopRight = texture(velocityMap, UVTopRight).x;
    
    float weightedBottomLeft = velocityBottomLeft * complement.x * complement.y;
    float weightedBottomRight = velocityBottomRight * frac.x * complement.y;
    float weightedTopLeft = velocityTopLeft * complement.x * frac.y;
    float weightedTopRight = velocityTopRight * frac.x * frac.y;

    return weightedBottomLeft + weightedBottomRight + weightedTopLeft + weightedTopRight;
}

float interpolateVelocityY(vec2 worldPos) {

    vec2 base = floor(worldPos - vec2(0.5, 0.5));
    vec2 frac = worldPos - base - vec2(0.5, 0.5);
    vec2 complement = 1.0 - frac;

    vec2 posBottomLeft = base;
    vec2 posBottomRight = base + vec2(1.0, 0.0);
    vec2 posTopLeft = base + vec2(0.0, 1.0);
    vec2 posTopRight = base + vec2(1.0, 1.0);

    vec2 UVBottomLeft = toUV(posBottomLeft);
    vec2 UVBottomRight = toUV(posBottomRight);
    vec2 UVTopLeft = toUV(posTopLeft);
    vec2 UVTopRight = toUV(posTopRight);

    float velocityBottomLeft = texture(velocityMap, UVBottomLeft).y;
    float velocityBottomRight = texture(velocityMap, UVBottomRight).y;
    float velocityTopLeft = texture(velocityMap, UVTopLeft).y;
    float velocityTopRight = texture(velocityMap, UVTopRight).y;

    float weightedBottomLeft = velocityBottomLeft * complement.x * complement.y;
    float weightedBottomRight = velocityBottomRight * frac.x * complement.y;
    float weightedTopLeft = velocityTopLeft * complement.x * frac.y;
    float weightedTopRight = velocityTopRight * frac.x * frac.y;

    return weightedBottomLeft + weightedBottomRight + weightedTopLeft + weightedTopRight;
}

vec2 interpolateMAC(vec2 worldPos) {

    return vec2(interpolateVelocityX(worldPos), interpolateVelocityY(worldPos));
}


vec2 interpolateVelocity(vec2 worldPos) {

    vec2 base = floor(worldPos);
    vec2 frac = worldPos - base;

    vec2 posCenter = base;
    vec2 posTopLeft = base + vec2(-1.0, 1.0);
    vec2 posTop = base + vec2(0.0, 1.0);
    vec2 posTopRight = base + vec2(1.0, 1.0);
    vec2 posLeft = base + vec2(-1.0, 0.0);
    vec2 posRight = base + vec2(1.0, 0.0);
    vec2 posBottom = base + vec2(0.0, -1.0);
    vec2 posBottomRight = base + vec2(1.0, -1.0);

    vec2 UVCenter = toUV(posCenter);
    vec2 UVTopLeft = toUV(posTopLeft);
    vec2 UVTop = toUV(posTop);
    vec2 UVTopRight = toUV(posTopRight);
    vec2 UVLeft = toUV(posLeft);
    vec2 UVRight = toUV(posRight);
    vec2 UVBottom = toUV(posBottom);
    vec2 UVBottomRight = toUV(posBottomRight);

    vec2 velocityCenter = texture(velocityMap, UVCenter).xy;
    vec2 velocityTopLeft = texture(velocityMap, UVTopLeft).xy;
    vec2 velocityTop = texture(velocityMap, UVTop).xy;
    vec2 velocityTopRight = texture(velocityMap, UVTopRight).xy;
    vec2 velocityLeft = texture(velocityMap, UVLeft).xy;
    vec2 velocityRight = texture(velocityMap, UVRight).xy;
    vec2 velocityBottom = texture(velocityMap, UVBottom).xy;
    vec2 velocityBottomRight = texture(velocityMap, UVBottomRight).xy;

    vec2 outputVelocity;

    if (frac.y >= 0.5) {

        float s = frac.x;
        float t = frac.y - 0.5;

        outputVelocity.x = velocityCenter.x * (1.0 - s) * (1.0 - t) +
                                 velocityTop.x * (1.0 - s) * t +
                                 velocityRight.x * s * (1.0 - t) +
                                 velocityTopRight.x * s * t;
    } else {

        float s = frac.x;
        float t = frac.y + 0.5;

        outputVelocity.x = velocityBottom.x * (1.0 - s) * (1.0 - t) +
                                 velocityCenter.x * (1.0 - s) * t +
                                 velocityBottomRight.x * s * (1.0 - t) +
                                 velocityRight.x * s * t;
    }

    if (frac.x >= 0.5) {

        float s = frac.x - 0.5;
        float t = frac.y;

        outputVelocity.y = velocityCenter.y * (1.0 - s) * (1.0 - t) +
                                 velocityTop.y * (1.0 - s) * t +
                                 velocityRight.y * s * (1.0 - t) +
                                 velocityTopRight.y * s * t;
    } else {

        float s = frac.x + 0.5;
        float t = frac.y;

        outputVelocity.y = velocityLeft.y * (1.0 - s) * (1.0 - t) +
                                 velocityTopLeft.y * (1.0 - s) * t +
                                 velocityCenter.y * s * (1.0 - t) +
                                 velocityTop.y * s * t;
    }

    return outputVelocity;
}

vec2 backstep() {

    vec2 cellVelocity = interpolatingSample(velocityMap, v_positionWorld.xy).xy; 
    return v_positionWorld.xy - (cellVelocity * dT);
    // return v_positionWorld.xy;
}


void main() {

    vec2 velocity;
    vec4 matter;

    if (texture(hydraulicsMap, v_uv).b == 0.0) {

        velocity = vec2(0.0, 0.0);
        matter = vec4(0.0, 0.0, 0.0, 0.0);

    } else {

        vec2 lastPos = backstep();

        velocity = interpolateMAC(lastPos);
        // velocity = interpolatingSample(velocityMap, lastPos).xy;
        matter = interpolatingSample(matterMap, lastPos);
    }

    // vec2 lastPos = backstep();

    // vec4 velocity = interpolatingSample(velocityMap, lastPos);
    // vec4 matter = interpolatingSample(matterMap, lastPos);

    vec2 currVelocity = interpolatingSample(velocityMap, v_positionWorld.xy).xy;


    // fragColor0 = texture(velocityMap, toUV(v_positionWorld.xy));
    fragColor0 = vec4(velocity.x, velocity.y, 0.0, 1.0);
    fragColor1 = matter;


}
