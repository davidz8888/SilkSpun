// src/core/BackgroundEntity.ts

import * as THREE from 'three';
import { Entity } from './Entity';
import defualtVertexShader from '../rendering/shaders/defaultVertex.glsl';
import backgroundFragmentShader from '../rendering/shaders/backgroundFragment.glsl';

export abstract class BackgroundEntity extends Entity {

    protected async createTHREEMesh(): Promise<THREE.Mesh> {
        const pathPrefix: string = './backgrounds/';
        const albedoMap: THREE.Texture = await BackgroundEntity.loadTexture(`${pathPrefix}${this.textureName}_albedo.png`);
        const normalMap: THREE.Texture = await BackgroundEntity.loadTexture(`${pathPrefix}${this.textureName}_normal.png`);

        // Create the square that faces the camera
        const backgroundGeometry: THREE.PlaneGeometry = new THREE.PlaneGeometry(albedoMap.image.width, albedoMap.image.height);
        const backgroundMaterial: THREE.ShaderMaterial = new THREE.ShaderMaterial({
            uniforms: {
                albedoMap: { value: albedoMap },
                normalMap: { value: normalMap },

            },
            glslVersion: THREE.GLSL3,
            vertexShader: defualtVertexShader,
            fragmentShader: backgroundFragmentShader
        });

        return new THREE.Mesh(backgroundGeometry, backgroundMaterial);
    }
}