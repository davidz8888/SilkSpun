// #version 300 es
// precision mediump float;

in vec3 v_positionWorld;
in vec2 v_uv;

uniform float screenWidth;
uniform float screenHeight;

uniform sampler2D background; 
uniform sampler2D foreground;
uniform sampler2D fluidMatter;

out vec4 fragColor;

void main() {

    vec4 backgroundInfo = texture(background, v_uv);
    vec4 foregroundInfo = texture(foreground, v_uv);
    vec4 fluidInfo = texture(fluidMatter, v_uv);

    vec3 solidsColor = (foregroundInfo.a * foregroundInfo.rgb) + ((1.0 - foregroundInfo.a) * backgroundInfo.rgb);
    vec3 combinedColor = (fluidInfo.a * fluidInfo.rgb) + ((1.0 - fluidInfo.a) * solidsColor);
    

    fragColor = vec4(combinedColor, backgroundInfo.a + foregroundInfo.a + fluidInfo.a);

    // fragColor = vec4(1, 1, 0, 1);

}