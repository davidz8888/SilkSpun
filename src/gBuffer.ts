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
