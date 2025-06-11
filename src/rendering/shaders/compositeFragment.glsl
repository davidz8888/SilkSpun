// #version 300 es
// precision mediump float;

in vec3 v_positionWorld;
in vec2 v_uv;

uniform float screenWidth;
uniform float screenHeight;

uniform sampler2D background; 
uniform sampler2D foreground;

out vec4 fragColor;

void main() {

    vec4 backgroundInfo = texture(background, v_uv);
    vec4 foregroundInfo = texture(foreground, v_uv);

    float alpha = foregroundInfo.a;

    vec3 combinedColor = (alpha * foregroundInfo.rgb) + ((1.0 - alpha) * backgroundInfo.rgb);

    fragColor = vec4(combinedColor, backgroundInfo.a + alpha);

    // fragColor = vec4(1, 1, 0, 1);

}