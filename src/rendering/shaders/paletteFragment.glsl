// #version 300 es

// Input data
in vec4 fragColor;

uniform vec3 palette[16]; // Example: a palette with 16 colors

out vec4 finalColor;

vec3 findClosestColor(vec3 color) {
    float minDist = 1e20;
    vec3 closestColor = palette[0];
    
    for (int i = 0; i < 16; i++) {
        float dist = distance(color, palette[i]);
        if (dist < minDist) {
            minDist = dist;
            closestColor = palette[i];
        }
    }
    
    return closestColor;
}

void main() {
    vec3 color = fragColor.rgb;

    vec3 mappedColor = findClosestColor(color);

    finalColor = vec4(mappedColor, 1.0);
}