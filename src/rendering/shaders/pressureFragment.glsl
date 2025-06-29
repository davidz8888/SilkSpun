precision highp float;

in vec3 v_positionWorld;
in vec3 v_viewPositionWorld;
in vec2 v_uv;

uniform float screenWidth;
uniform float screenHeight;

uniform sampler2D hydraulicsMap;
uniform sampler2D divergenceMap;
uniform sampler2D pressureMap;

out vec4 fragColor;

float OVER_RELAXATION = 1.0;

vec2 toUV(vec2 worldPos) { 
    return vec2(worldPos.x/screenWidth, worldPos.y/screenHeight) + 0.5;
}


void main() {

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

    float pressureLeft = texture(pressureMap, UVLeft).r;
    float pressureRight = texture(pressureMap, UVRight).r;
    float pressureUp = texture(pressureMap, UVUp).r;
    float pressureDown = texture(pressureMap, UVDown).r;

    float solidityCenter = texture(hydraulicsMap, UVCenter).b;
    float solidityLeft = texture(hydraulicsMap, UVLeft).b;
    float solidityRight = texture(hydraulicsMap, UVRight).b;
    float solidityUp = texture(hydraulicsMap, UVUp).b;
    float solidityDown = texture(hydraulicsMap, UVDown).b;

    float divergence = texture(divergenceMap, UVCenter).r;

    // Solid neighbors contribute nothing
    float pressureSum = 0.0;
    float solidityCount = 0.0;

    if (solidityLeft == 1.0) { pressureSum += pressureLeft; solidityCount += 1.0; }
    if (solidityRight == 1.0) { pressureSum += pressureRight; solidityCount += 1.0; }
    if (solidityUp == 1.0) { pressureSum += pressureUp; solidityCount += 1.0; }
    if (solidityDown == 1.0) { pressureSum += pressureDown; solidityCount += 1.0; }

    float pressureJacobi = (pressureSum - divergence) / max(solidityCount, 1.0);
    vec4 pressure = texture(pressureMap, UVCenter);
    pressure.r = solidityCenter < 1.0 ? 0.0 : mix(pressure.r, pressureJacobi, OVER_RELAXATION);

    fragColor = pressure;
}