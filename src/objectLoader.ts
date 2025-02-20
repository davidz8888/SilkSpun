import * as THREE from 'three';

export function createGBuffer(width: number, height: number) {
    const albedoBuffer: THREE.WebGLRenderTarget = new THREE.WebGLRenderTarget(width, height, {
        minFilter: THREE.NearestFilter,
        magFilter: THREE.NearestFilter,
    });
    
    const normalBuffer: THREE.WebGLRenderTarget = new THREE.WebGLRenderTarget(width, height, {
        minFilter: THREE.NearestFilter,
        magFilter: THREE.NearestFilter,
    });
    
    const depthBuffer: THREE.WebGLRenderTarget = new THREE.WebGLRenderTarget(width, height, {
        minFilter: THREE.NearestFilter,
        magFilter: THREE.NearestFilter,
    });
    
    const gBuffer = {
        albedoBuffer,
        normalBuffer,
        depthBuffer
    };

    return gBuffer;
}

export function GBuffer(width: number, height: number): THREE.WebGLRenderTarget {
    return new THREE.WebGLRenderTarget(width, height, {
        minFilter: THREE.NearestFilter,
        magFilter: THREE.NearestFilter,
        count: 3
    });
}

const textureLoader: THREE.TextureLoader = new THREE.TextureLoader();

import vertexShader from './shaders/vertex.glsl';
import fragmentShader from './shaders/fragment.glsl';

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
        vertexShader,
        fragmentShader
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
