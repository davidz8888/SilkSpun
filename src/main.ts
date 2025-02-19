import * as THREE from 'three';
import Stats from 'stats-js';
import { GBuffer } from './gBuffer';
import { createObjectFromFile } from './objectLoader';
// import { defaultLight } from './light';

import vertexShader from './shaders/vertex.glsl';
//import fragmentShader from './shaders/fragment.glsl';
import lightingShader from './shaders/lighting.glsl';
//import fragmentDebugShader from './shaders/fragmentDebug.glsl';

const stats: Stats = new Stats();
document.body.appendChild(stats.dom); // Add FPS counter to the webpage

const sceneScale: number = 100;
const sceneWidth: number = (sceneScale * window.innerWidth) / window.innerHeight;
const sceneHeight: number = sceneScale;

const renderer: THREE.WebGLRenderer = new THREE.WebGLRenderer({ antialias: false, preserveDrawingBuffer: true });
renderer.setSize(sceneWidth, sceneHeight);
document.body.appendChild(renderer.domElement);

const gBuffer: THREE.WebGLRenderTarget = GBuffer(sceneWidth, sceneHeight);

const geometryScene: THREE.Scene = new THREE.Scene();
const camera: THREE.OrthographicCamera = new THREE.OrthographicCamera(
    -sceneWidth / 2,
    sceneWidth / 2,
    sceneHeight / 2,
    -sceneHeight / 2,
    0,
    100
);

async function setupScene(): Promise<void> {
    const testObject: THREE.Object3D = await createObjectFromFile('beams');
    testObject.position.set(0, 0, -1);
    geometryScene.add(testObject);

    const backgroundObject: THREE.Object3D = await createObjectFromFile('background');
    backgroundObject.position.set(0, 0, -3);
    geometryScene.add(backgroundObject);
}

// const lightData = [defaultLight(5, 5, -3)];

// Flatten the array of structs into a single array of values
// const flattenedData: number[] = lightData.reduce((acc: number[], { positionWorld, color, falloff, radius }) => {
//     return acc.concat(positionWorld, color, falloff, radius);
// }, []);

// Create a buffer for the uniform data
// const lightBuffer: THREE.BufferAttribute = new THREE.BufferAttribute(new Float32Array(flattenedData), 1);

const lightingScene: THREE.Scene = new THREE.Scene();
const lightingMaterial: THREE.ShaderMaterial = new THREE.ShaderMaterial({
    uniforms: {
        // lightBuffer: { value: lightBuffer },
        screenWidth: { value: sceneWidth },
        screenHeight: { value: sceneHeight },
        albedoMap: { value: gBuffer.textures[0] }, // Albedo texture
        normalMap: { value: gBuffer.textures[1] }, // Normal texture
        heightMap: { value: gBuffer.textures[2] }, // Depth texture
    },
    glslVersion: THREE.GLSL3,
    vertexShader: vertexShader,
    fragmentShader: lightingShader,
});

const lightingQuad: THREE.Mesh = new THREE.Mesh(new THREE.PlaneGeometry(sceneWidth, sceneHeight), lightingMaterial);
lightingScene.add(lightingQuad);
lightingQuad.position.set(0, 0, -1.0);

const lightingTarget: THREE.WebGLRenderTarget = new THREE.WebGLRenderTarget(sceneWidth, sceneHeight);

const screenScene: THREE.Scene = new THREE.Scene();
const screenMaterial: THREE.MeshBasicMaterial = new THREE.MeshBasicMaterial({
    map: Object.assign(lightingTarget.texture, {
      minFilter: THREE.NearestFilter,
      magFilter: THREE.NearestFilter,
    }),
  });
const screenQuad: THREE.Mesh = new THREE.Mesh(new THREE.PlaneGeometry(sceneWidth, sceneHeight), screenMaterial);
screenScene.add(screenQuad);

function render(): void {
    stats.begin(); // Start measuring
    requestAnimationFrame(render);

    // Render scene to the render target
    renderer.setRenderTarget(gBuffer);
    renderer.render(geometryScene, camera);

    renderer.setRenderTarget(lightingTarget);
    renderer.render(lightingScene, camera);

    renderer.setRenderTarget(null);
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.render(screenScene, camera);

    stats.end(); // Stop measuring
}

setupScene().then(render);
