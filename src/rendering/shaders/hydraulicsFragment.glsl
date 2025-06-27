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
float OVER_RELAXATION = 2.0;
float dT = 1.0 / 60.0;
float EPSILON = 0.01; 

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

float zeroIfClose(float value) {
    return abs(value) < EPSILON ? 0.0 : value;
}



vec2 calculateVelocities() {
    
    vec2 cellVelocity = texture(flowMap, v_uv).xy;

    vec2 cellAcceleration = texture(hydraulicsMap, v_uv).xy;
    cellAcceleration.x = zeroIfClose(normalizeInfo(cellAcceleration.x));
    cellAcceleration.y = zeroIfClose(normalizeInfo(cellAcceleration.y));

    vec2 posCenter = vec2(v_positionWorld.xy);
    vec2 posLeft = vec2(v_positionWorld.x - 1.0, v_positionWorld.y);
    vec2 posDown = vec2(v_positionWorld.x, v_positionWorld.y - 1.0);

    float solidityCenter = normalizeSolidity(texture(hydraulicsMap, toUV(posCenter)).b);
    float solidityLeft = normalizeSolidity(texture(hydraulicsMap, toUV(posLeft)).b);
    float solidityDown = normalizeSolidity(texture(hydraulicsMap, toUV(posDown)).b);

    // cellVelocity.x = (cellVelocity.x + (cellAcceleration.x * dT * OVER_RELAXATION)) * (solidityCenter * solidityLeft);
    // cellVelocity.y = (cellVelocity.y + (cellAcceleration.y * dT * OVER_RELAXATION)) * (solidityCenter * solidityDown);

    cellVelocity.x = (cellVelocity.x + (cellAcceleration.x * dT * OVER_RELAXATION));
    cellVelocity.y = (cellVelocity.y + (cellAcceleration.y * dT * OVER_RELAXATION));

    // cellVelocity.x = (cellVelocity.x + (0.01 * dT * OVER_RELAXATION));
    // cellVelocity.y = (cellVelocity.y + (0.01 * dT * OVER_RELAXATION));

    return cellVelocity;
}

vec2 debugVelocities() {
    
    vec2 cellVelocity = texture(flowMap, v_uv).xy;

    vec2 cellAcceleration = texture(hydraulicsMap, v_uv).xy;
    cellAcceleration.x = zeroIfClose(normalizeInfo(cellAcceleration.x));
    cellAcceleration.y = zeroIfClose(normalizeInfo(cellAcceleration.y));

    vec2 posCenter = vec2(v_positionWorld.xy);
    vec2 posLeft = vec2(v_positionWorld.x - 1.0, v_positionWorld.y);
    vec2 posDown = vec2(v_positionWorld.x, v_positionWorld.y - 1.0);


    // 26.2 == 14
    // 13.2 == 8
    // cellVelocity.x = 12.2 * cellAcceleration.x * 30.0;
    // cellVelocity.y = 1.0 * cellAcceleration.y;
    // cellVelocity.x = 30.2;

    if (cellAcceleration.x > 0.5) {
        cellVelocity.x = 16.2 * 30.0;
        cellVelocity.y = 0.0;
    }

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

    // if (texture(hydraulicsMap, v_uv).b == 1.0) {
    //     fragColor0 = vec4(0.0);
    //     fragColor1 = vec4(0.0);
    // }
    
    vec4 hydraulics = texture(hydraulicsMap, v_uv);
    vec4 flow = texture(flowMap, v_uv);
    // vec2 cellVelocity = calculateVelocities();

    // vec2 cellVelocity = vec2(1.0);
    vec2 cellVelocity = debugVelocities();
    

    fragColor0 = vec4(cellVelocity.x, cellVelocity.y, flow.b, flow.a);
    // fragColor0 = vec4(35.0, 0.0, 0.0, 0.0);
    fragColor1 = calculateEmissions();
}
