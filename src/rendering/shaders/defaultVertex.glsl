precision highp float;

out highp vec3 v_positionWorld;    // World position of the vertex
out vec3 v_viewPositionWorld;
out vec3 v_normalWorld;      // Normal in world space
out vec2 v_uv;               // Texture coordinates


void main() {
    // Calculate the world position by multiplying the model matrix with the vertex position
    vec4 worldPosition = modelMatrix * vec4(position, 1.0);

    // Pass data to the fragment shader
    v_positionWorld = worldPosition.xyz;

    v_normalWorld = mat3(modelMatrix) * normal; // Transform normal into world space
    v_uv = uv;

    // Final position in clip space
    gl_Position = projectionMatrix * viewMatrix * worldPosition;
}