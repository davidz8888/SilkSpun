import * as THREE from 'three';

import defualtVertexShader from './shaders/defaultVertex.glsl';
import geometryFragmentShader from './shaders/geometryFragment.glsl';
import backgroundFragmentShader from './shaders/backgroundFragment.glsl';

const textureLoader: THREE.TextureLoader = new THREE.TextureLoader();

export async function createObjectFromFile(name: string): Promise<THREE.Mesh> {
    const pathPrefix: string = './objects/';
    const albedoMap: THREE.Texture = await loadTexture(`${pathPrefix}${name}_albedo.png`);
    const normalMap: THREE.Texture = await loadTexture(`${pathPrefix}${name}_normal.png`);
    const heightMap: THREE.Texture = await loadTexture(`${pathPrefix}${name}_height.png`);

    // Create the square that faces the camera
    const objectGeometry: THREE.PlaneGeometry = new THREE.PlaneGeometry(albedoMap.image.width, albedoMap.image.height);
    const objectMaterial: THREE.ShaderMaterial = new THREE.ShaderMaterial({
        uniforms: {
            albedoMap: { value: albedoMap },
            normalMap: { value: normalMap },
            heightMap: { value: heightMap },
        },
        glslVersion: THREE.GLSL3,
        vertexShader: defualtVertexShader,
        fragmentShader: geometryFragmentShader
    });
    const object: THREE.Mesh = new THREE.Mesh(objectGeometry, objectMaterial);

    return object;
}

export async function createBackgroundFromFile(name: string): Promise<THREE.Mesh> {
    const pathPrefix: string = './objects/';
    const albedoMap: THREE.Texture = await loadTexture(`${pathPrefix}${name}_albedo.png`);
    const normalMap: THREE.Texture = await loadTexture(`${pathPrefix}${name}_normal.png`);

    // Create the square that faces the camera
    const objectGeometry: THREE.PlaneGeometry = new THREE.PlaneGeometry(albedoMap.image.width, albedoMap.image.height);
    const objectMaterial: THREE.ShaderMaterial = new THREE.ShaderMaterial({
        uniforms: {
            albedoMap: { value: albedoMap },
            normalMap: { value: normalMap },
        },
        glslVersion: THREE.GLSL3,
        vertexShader: defualtVertexShader,
        fragmentShader: backgroundFragmentShader
    });
    const object: THREE.Mesh = new THREE.Mesh(objectGeometry, objectMaterial);

    return object;
}



function loadTexture(url: string): Promise<THREE.Texture> {
    return new Promise((resolve, reject) => {
        textureLoader.load(
            url,
            (texture: THREE.Texture) => {
                texture.minFilter = THREE.NearestFilter;
                texture.magFilter = THREE.NearestFilter;
                console.log(`✅ Loaded texture successfully: ${url}`);
                resolve(texture);
            },
            undefined,
            (error: any) => {
                console.error(`❌ Failed to load texture: ${url}`, error);
                reject(error);
            }
        );
    });
}
