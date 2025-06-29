precision highp float;

in vec3 v_positionWorld;
in vec3 v_viewPositionWorld;
in vec2 v_uv;

uniform float screenWidth;
uniform float screenHeight;

uniform sampler2D hydraulicsMap;
uniform sampler2D velocityMap;
uniform sampler2D matterMap;

out vec4 fragColor;


vec2 toUV(vec2 worldPos) { 
    return vec2(worldPos.x/screenWidth, worldPos.y/screenHeight) + 0.5;
}

float calculateDivergence() {

    vec2 posCenter = v_positionWorld.xy;
    vec2 posLeft = posCenter + vec2(-1.0, 0.0);
    vec2 posRight = posCenter + vec2(1.0, 0.0);
    vec2 posUp = posCenter + vec2(0.0, 1.0);
    vec2 posDown = posCenter + vec2(0.0, -1.0);

    vec2 UVCenter = toUV(posCenter);
    vec2 UVLeft = toUV(posLeft);
    vec2 UVRight = toUV(posRight);
    vec2 UVUp = toUV(posUp);
    vec2 UVDown = toUV(posDown);

    float velocityLeft = texture(velocityMap, UVCenter).r;
    float velocityRight = texture(velocityMap, UVRight).r;
    float velocityUp = texture(velocityMap, UVUp).g;
    float velocityDown = texture(velocityMap, UVCenter).g;

    float solidityLeft = texture(hydraulicsMap, UVLeft).b;
    float solidityRight = texture(hydraulicsMap, UVRight).b;
    float solidityUp = texture(hydraulicsMap, UVUp).b;
    float solidityDown = texture(hydraulicsMap, UVDown).b;

    float divergence = -velocityLeft + velocityRight + velocityUp + -velocityDown;
    float neighbourSolidity = solidityLeft + solidityRight + solidityUp + solidityDown;

    float result = neighbourSolidity >= 1.0 ? (divergence / neighbourSolidity) : 0.0;
    return result;
}

void main() {

    float divergence = calculateDivergence();
    fragColor = vec4(divergence, 0.0, 0.0, 1.0);
}
