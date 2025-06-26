// #version 300 es
// precision mediump float;

in vec3 v_positionWorld;
in vec2 v_uv;

uniform float screenWidth;
uniform float screenHeight;

uniform sampler2D background; 
uniform sampler2D foreground;
uniform sampler2D flowMap;
uniform sampler2D matterMap;


out vec4 fragColor;

void main() {

    vec4 background = texture(background, v_uv);
    vec4 foreground = texture(foreground, v_uv);
    vec4 flow = texture(flowMap, v_uv);
    vec4 matter = texture(matterMap, v_uv);

    vec3 solidsColor = (foreground.a * foreground.rgb) + ((1.0 - foreground.a) * background.rgb);
    vec3 combinedColor = (matter.a * matter.rgb) + ((1.0 - matter.a) * solidsColor);
    

    // fragColor = vec4(combinedColor, background.a + foreground.a + matter.a);
 
    // fragColor = vec4(flow.g);
    fragColor = matter;
    // fragColor = flow;

    // fragColor = vec4(flow.b);
}