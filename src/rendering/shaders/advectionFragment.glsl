// #version 300 es
// precision mediump float;

in vec3 v_positionWorld;
in vec3 v_viewPositionWorld;
in vec2 v_uv;

uniform float screenWidth;
uniform float screenHeight;

uniform sampler2D hydraulicsMap;
uniform sampler2D matterMap;

out vec4 fragColor;

float overRelaxation = 2.0;

float velocityLeft;
float velcoityRight;
float velocityUp;
float velocityDown;

vec4 matter;

vec2 toUV(vec3 worldPos) { 
    return vec2(worldPos.x/screenWidth, worldPos.y/screenHeight) + 0.5;
}

applyForces() {
    
}

applyProjection() {

    vec2 currPos = vec2(v_positionWorld.xy);
    vec2 leftPos = vec2(currPos.x - 1.0, currPos.y);
    vec2 rightPos = vec2(currPos.x + 1.0, currPos.y);
    vec2 upPos = vec2(currPos.x, currPos.y + 1.0);
    vec2 downPos = vec2(currPos.x, currPos.y - 1.0);

    vec2 currUV = toUV(currPos);
    vec2 leftUV = toUV(leftPos);
    vec2 rightUV = toUV(rightPos);
    vec2 upUV = toUV(upPos);
    vec2 downUV = toUV(downUV);


    float velocityLeft = texture(velocityMap, currUV).r;
    float velocityRight = texture(velocityMap, rightUV).r;
    float velocityUp = texture(velocityMap, upUV).g;
    float velocityDown = texture(velocityMap, currUV).g;

    float solidityLeft = texture(hydraulicsMap.b, leftUV);
    float solidityRight = texture(hydraulicsMap.b, rightUV);
    float solidityUp = texture(hydraulicsMap.b, upUV);
    float solidityDown = texture(hydraulicsMap.b, upDown);

    velocityLeft += divergence * solidityLeft;
    velocityRight -= divergence * solidityRight;
    velocityUp -= divergence * solidityUp;
    velocityDown += divergence * solidiyDown;

    return vec4(velocityLeft, velocityRight, velocityUp, velocityDown);
}

advection(float dT) {

    vec2 lastPos = vec2(v_positionWorld.x - (dT * velocityX), v_positionWorld.y - (dT * velocityY));
    vec2 lastPosRight = vec2(lastPos.x + 1.0, lastPos.y);
    vec2 lastPosUp = vec2(lastPos.x, lastPos.y + 1.0);

    vec2 lastUV = toUV(lastPos);
    vec2 lastRightUV = toUV(lastPos);
    vec2 lastUpUV = toUV(lastUpUV);

    matter = texture(matterMap, lastUV);
}

calculateDivergence() {

    vec2 currPos = vec2(v_positionWorld.xy);
    vec2 leftPos = vec2(v_positionWorld.x - 1.0, v_positionWorld.y);
    vec2 rightPos = vec2(v_positionWorld.x + 1.0, v_positionWorld.y);
    vec2 upPos = vec2(v_positionWorld.x, v_positionWorld.y + 1.0);
    vec2 downPos = vec2(v_positionWorld.x, v_positionWorld - 1.0);

    vec2 currUV = toUV(currPos);
    vec2 leftUV = toUV(leftPos);
    vec2 rightUV = toUV(rightPos);
    vec2 upUV = toUV(upPos);
    vec2 downUV = toUV(downUV);

    float velocityLeft = texture(velocityMap, currUV).r;
    float velocityRight = texture(velocityMap, rightUV).r;
    float velocityUp = texture(velocityMap, upUV).g;
    float velocityDown = texture(velocityMap, currUV).g;

    float solidityLeft = texture(hydraulicsMap.b, leftUV);
    float solidityRight = texture(hydraulicsMap.b, rightUV);
    float solidityUp = texture(hydraulicsMap.b, upUV);
    float solidityDown = texture(hydraulicsMap.b, upDown);

    float divergence = -velocityLeft + velocityRight + velocityUp + -velocityDown;
    float neighbourSolidity = solidityLeft + solidityRight + solidityUp + solidityDown;

    return divergence * overRelaxation / neighbourSolidity;
}

main() {
    fragColor = advectMatter();
}
