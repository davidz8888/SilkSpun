precision highp float;

in vec3 v_positionWorld;
in vec2 v_uv;

uniform float screenWidth;
uniform float screenHeight;

uniform sampler2D backgroundMap; 
uniform sampler2D foregroundMap;
uniform sampler2D hydraulicsMap;
uniform sampler2D initialVelocityMap;
uniform sampler2D injectedVelocityMap;
uniform sampler2D advectedVelocityMap;
uniform sampler2D projectedVelocityMap;
uniform sampler2D matterMap;
uniform sampler2D divergenceMap;
uniform sampler2D pressureMapA;
uniform sampler2D pressureMapB;


out vec4 fragColor;

vec4 safeColor(vec4 c) {
    return (c.r != c.r) ? vec4(0.0, 1.0, 0.0, 1.0) : c;
}

vec4 velocityToColor(vec4 velocity) {

    float red = velocity.x + 0.5;
    float green = velocity.y + 0.5;
    float blue = 0.5;
    return vec4(red, green, blue, 1.0);
}

void main() {

    vec4 background = texture(backgroundMap, v_uv);
    vec4 foreground = texture(foregroundMap, v_uv);
    vec4 hydraulics = texture(hydraulicsMap, v_uv);

    vec4 initialVelocity = texture(initialVelocityMap, v_uv);
    vec4 injectedVelocity = texture(injectedVelocityMap, v_uv);
    vec4 advectedVelocity = texture(advectedVelocityMap, v_uv);
    vec4 projectedVelocity = texture(projectedVelocityMap, v_uv);
    vec4 matter = texture(matterMap, v_uv);
    vec4 divergence = texture(divergenceMap, v_uv);
    vec4 pressureA = texture(pressureMapA, v_uv);
    vec4 pressureB = texture(pressureMapB, v_uv);

    vec3 solidsColor = (foreground.a * foreground.rgb) + ((1.0 - foreground.a) * background.rgb);
    vec3 combinedColor = (matter.a * matter.rgb) + ((1.0 - matter.a) * solidsColor);
    
    // fragColor = foreground;
    fragColor = vec4(solidsColor.r, solidsColor.g, solidsColor.b, 1.0);
    // fragColor = vec4(combinedColor, background.a + foreground.a + matter.a);
           

    vec4 coloredPressure = safeColor(vec4(pressureA.r, 0.0, -pressureA.r, 1.0));
    vec4 coloredDivergence = vec4(-divergence.r, 0.0, divergence.r, 0.0);
    
    
    // fragColor = safeColor(coloredPressure);
    // fragColor = matter;
    // fragColor = coloredDivergence * 5.0;
    // fragColor = velocityToColor(initialVelocity);
    // fragColor = velocityToColor(injectedVelocity);
    // fragColor = velocityToColor(advectedVelocity);
    // fragColor = velocityToColor(projectedVelocity);

    // fragColor = coloredPressure;
    // fragColor = hydraulics;
    // fragColor = safeColor(vec4(abs(velocity.r)));
    // fragColor = vec4(velocity.y);
    // fragColor = velocity;

    vec2 base = floor(v_positionWorld.xy);
    vec2 frac = v_positionWorld.xy - base;

    // fragColor = vec4(frac.x, frac.y, 0.0, 1.0);
}