import * as THREE from 'three';
import Stats from 'stats-js';
import { GBuffer } from './gBuffer';
import { createObjectFromFile, createBackgroundFromFile } from './assetLoader';
import { PointLight, SkyLight, InfiniteLight } from './light';

import defaultVertexShader from './shaders/defaultVertex.glsl';
import geometryFragmentShader from './shaders/geometryFragment.glsl';
import lightingFragmentShader from './shaders/lightingFragment.glsl';
import compositeFragmentShader from './shaders/compositeFragment.glsl';

const stats: Stats = new Stats();
document.body.appendChild(stats.dom); // Add FPS counter to the webpage

const sceneScale: number = 176;
const sceneWidth: number = (sceneScale * window.innerWidth) / window.innerHeight;
const sceneHeight: number = sceneScale;

const renderer: THREE.WebGLRenderer = new THREE.WebGLRenderer({ antialias: false, preserveDrawingBuffer: true });
renderer.setSize(sceneWidth, sceneHeight);
document.body.appendChild(renderer.domElement);


const backgroundScene: THREE.Scene = new THREE.Scene();
const backgroundObject: THREE.Object3D = await createBackgroundFromFile('background');
backgroundObject.position.set(0, 0, -50);
backgroundScene.add(backgroundObject);

const mountainsObject: THREE.Object3D = await createBackgroundFromFile('mountains');
backgroundObject.position.set(0, 0, -50);
backgroundScene.add(mountainsObject);

const backgroundTarget: THREE.WebGLRenderTarget = new THREE.WebGLRenderTarget(sceneWidth, sceneHeight); 

const gBuffer: THREE.WebGLRenderTarget = GBuffer(sceneWidth, sceneHeight);

const geometryScene: THREE.Scene = new THREE.Scene();
const camera: THREE.OrthographicCamera = new THREE.OrthographicCamera(
    -sceneWidth / 2,
    sceneWidth / 2,
    sceneHeight / 2,
    -sceneHeight / 2,
    0,
    1000
);

const beamsObject: THREE.Object3D = await createObjectFromFile('beams');
beamsObject.position.set(0, 0, -3);
geometryScene.add(beamsObject);

const pointLights: PointLight[] = [];
pointLights.push({
    positionWorld: new THREE.Vector3(50.0, 50.0, 15.0),
    color: new THREE.Vector3(1.0, 1.0, 1.0),
    falloff: 0.2,
    radius: 300.0
});
pointLights.push({
    positionWorld: new THREE.Vector3(-50.0, -50.0, 15.0),
    color: new THREE.Vector3(0.0, 1.0, 1.0),
    falloff: 0.2,
    radius: 0.0
});
pointLights.push({
    positionWorld: new THREE.Vector3(-50.0, 50.0, 15.0),
    color: new THREE.Vector3(1.0, 1.0, 0.0),
    falloff: 0.2,
    radius: 0.0
});
pointLights.push({
    positionWorld: new THREE.Vector3(50.0, -50.0, 15.0),
    color: new THREE.Vector3(0.0, 0.0, 1.0),
    falloff: 0.2,
    radius: 0.0
});

const skyLight: SkyLight = {
    color: new THREE.Vector3(0.5, 0.8, 1.0),
    shadowDistance: 20.0
};

const lightingScene: THREE.Scene = new THREE.Scene();
const lightingUniforms = {
    screenWidth: { value: sceneWidth },
    screenHeight: { value: sceneHeight },
    albedoMap: { value: gBuffer.textures[0] },
    normalMap: { value: gBuffer.textures[1] },
    heightMap: { value: gBuffer.textures[2] }, 
    pointLights: { value: pointLights },
    numPointLightsInUse: { value: pointLights.length },
    skyLight: { value: skyLight }

};
const lightingMaterial: THREE.ShaderMaterial = new THREE.ShaderMaterial({
    uniforms: lightingUniforms,
    glslVersion: THREE.GLSL3,
    vertexShader: defaultVertexShader,
    fragmentShader: lightingFragmentShader,
});

const lightingQuad: THREE.Mesh = new THREE.Mesh(new THREE.PlaneGeometry(sceneWidth, sceneHeight), lightingMaterial);
lightingScene.add(lightingQuad);
lightingQuad.position.set(0, 0, -1.0);

const lightingTarget: THREE.WebGLRenderTarget = new THREE.WebGLRenderTarget(sceneWidth, sceneHeight);


const compositeScene: THREE.Scene = new THREE.Scene();
const compositeUniforms = {
    screenWidth: { value: sceneWidth },
    screenHeight: { value: sceneHeight },
    background: { value: backgroundTarget.texture },
    foreground: { value: lightingTarget.texture },

};
const compositeMaterial: THREE.ShaderMaterial = new THREE.ShaderMaterial({
    uniforms: compositeUniforms,
    glslVersion: THREE.GLSL3,
    vertexShader: defaultVertexShader,
    fragmentShader: compositeFragmentShader,
})

const compositeQuad: THREE.Mesh = new THREE.Mesh(new THREE.PlaneGeometry(sceneWidth, sceneHeight), compositeMaterial);
compositeScene.add(compositeQuad);

// const screenScene: THREE.Scene = new THREE.Scene();
// const screenMaterial: THREE.MeshBasicMaterial = new THREE.MeshBasicMaterial({
//     map: Object.assign(compositeTarget.texture, {
//       minFilter: THREE.NearestFilter,
//       magFilter: THREE.NearestFilter,
//     }),
//   });
// const screenQuad: THREE.Mesh = new THREE.Mesh(new THREE.PlaneGeometry(sceneWidth, sceneHeight), screenMaterial);
// screenScene.add(screenQuad);

function render(): void {
    stats.begin(); 
    requestAnimationFrame(render);

    renderer.setRenderTarget(backgroundTarget);
    renderer.render(backgroundScene, camera);

    renderer.setRenderTarget(gBuffer);
    renderer.render(geometryScene, camera);

    renderer.setRenderTarget(lightingTarget);
    renderer.render(lightingScene, camera);

    renderer.setRenderTarget(null);
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.render(compositeScene, camera);

    stats.end();
}

render();
