// #version 300 es
// precision mediump float;

in vec3 v_positionWorld;
in vec3 v_viewPositionWorld;
in vec2 v_uv;

uniform float screenWidth;
uniform float screenHeight;

uniform sampler2D hydraulicsMap;
uniform sampler2D emissionsMap;
uniform sampler2D flowMap;
uniform sampler2D matterMap;

layout(location = 0) out vec4 fragColor0; // Flow
layout(location = 1) out vec4 fragColor1; // Matter

float NORMALIZATION_FACTOR = 1.0;

vec2 toUV(vec2 worldPos) { 
    return vec2(worldPos.x/screenWidth, worldPos.y/screenHeight) + 0.5;
}

float normalizeInfo(float info) {
    return ((info * 2.0) - 1.0) * NORMALIZATION_FACTOR;
}

float encodeInfo(float info) {
    return ((info / NORMALIZATION_FACTOR) + 1.0) / 2.0;
}

float normalizeSolidity(float solidity) {
    return (solidity - 1.0) * -1.0;
}



vec2 calculateVelocities() {
    
    vec2 cellVelocity = texture(flowMap, v_uv).xy;
    cellVelocity.x = normalizeInfo(cellVelocity.x);
    cellVelocity.y = normalizeInfo(cellVelocity.y);

    vec2 cellAcceleration = texture(hydraulicsMap, v_uv).xy;
    cellAcceleration.x = normalizeInfo(cellAcceleration.x);
    cellAcceleration.y = normalizeInfo(cellAcceleration.y);

    vec2 posCenter = vec2(v_positionWorld.xy);
    vec2 posLeft = vec2(v_positionWorld.x - 1.0, v_positionWorld.y);
    vec2 posDown = vec2(v_positionWorld.x, v_positionWorld.y - 1.0);

    float solidityCenter = normalizeSolidity(texture(hydraulicsMap, toUV(posCenter)).b);
    float solidityLeft = normalizeSolidity(texture(hydraulicsMap, toUV(posLeft)).b);
    float solidityDown = normalizeSolidity(texture(hydraulicsMap, toUV(posDown)).b);

    cellVelocity.x = (cellVelocity.x + cellAcceleration.x) * (solidityCenter * solidityLeft);
    cellVelocity.y = (cellVelocity.y + cellAcceleration.y) * (solidityCenter * solidityDown);

    return cellVelocity;
}

vec2 debugVelocities() {
    vec2 cellVelocity = texture(flowMap, v_uv).xy;

    cellVelocity.x += 0.01;
    cellVelocity.y += 0.01;

    return cellVelocity;
}


vec4 calculateEmissions() {
    
    vec4 matter = texture(matterMap, v_uv);
    vec4 emission = texture(emissionsMap, v_uv);
    
    // float isZero = float(all(lessThan(abs(matter), vec4(1e-6))));
    // vec4 result = mix(matter, matter + emission, isZero);

    matter += emission;

    // return emission;
    return matter;
}

void main() {
    vec4 hydraulics = texture(hydraulicsMap, v_uv);
    vec4 flow = texture(flowMap, v_uv);
    vec2 cellVelocity = calculateVelocities();
    cellVelocity.x = encodeInfo(cellVelocity.x);
    cellVelocity.y = encodeInfo(cellVelocity.y);
    // vec2 cellVelocity = vec2(1.0);
    // vec2 cellVelocity = debugVelocities();
    

    fragColor0 = vec4(cellVelocity.x, cellVelocity.y, flow.b, flow.a);
    fragColor1 = calculateEmissions();
    // fragColor1 = hydraulics;
}
