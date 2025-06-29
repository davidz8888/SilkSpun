// #version 300 es
// precision mediump float;

in vec3 v_positionWorld;
in vec2 v_uv;

uniform float screenWidth;
uniform float screenHeight;

uniform sampler2D background; 
uniform sampler2D foreground;
uniform sampler2D hydraulicsMap;
uniform sampler2D velocityMap;
uniform sampler2D matterMap;
uniform sampler2D divergenceMap;
uniform sampler2D pressureMapA;
uniform sampler2D pressureMapB;


out vec4 fragColor;

vec4 safeColor(vec4 c) {
    return (c.r != c.r) ? vec4(1.0, 0.0, 1.0, 1.0) : c;
}

void main() {

    vec4 background = texture(background, v_uv);
    vec4 foreground = texture(foreground, v_uv);
    vec4 velocity = texture(velocityMap, v_uv);
    vec4 matter = texture(matterMap, v_uv);
    vec4 divergence = texture(divergenceMap, v_uv);
    vec4 pressureA = texture(pressureMapA, v_uv);
    vec4 pressureB = texture(pressureMapB, v_uv);

    vec3 solidsColor = (foreground.a * foreground.rgb) + ((1.0 - foreground.a) * background.rgb);
    vec3 combinedColor = (matter.a * matter.rgb) + ((1.0 - matter.a) * solidsColor);
    
    // fragColor = vec4(solidsColor.r, solidsColor.g, solidsColor.b, 1.0);
    // fragColor = vec4(combinedColor, background.a + foreground.a + matter.a);
 
    // vec4 coloredPressure = vec4(pressureA.r, abs(divergence.r), -pressureA.r, 1.0);
    vec4 coloredPressure = vec4(pressureA.r, 0.0, -pressureA.r, 1.0);

    // fragColor = safeColor(coloredPressure);
    fragColor = matter;
    // fragColor = safeColor(vec4(abs(velocity.r)));
    // fragColor = vec4(velocity.y);
}