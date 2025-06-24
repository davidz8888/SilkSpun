// src/core/ForegroundEntity.ts

import * as THREE from 'three';
import { Entity } from './Entity';
import defualtVertexShader from '../rendering/shaders/defaultVertex.glsl';
import geometryFragmentShader from '../rendering/shaders/geometryFragment.glsl';

export abstract class ForegroundEntity extends Entity {

    

    protected async createTHREEMesh(): Promise<THREE.Mesh> {
        const pathPrefix: string = './assets/textures/';
        const albedoMap: THREE.Texture = await ForegroundEntity.loadTexture(`${pathPrefix}${this.textureName}_albedo.png`);
        const normalMap: THREE.Texture = await ForegroundEntity.loadTexture(`${pathPrefix}${this.textureName}_normal.png`);
        const heightMap: THREE.Texture = await ForegroundEntity.loadTexture(`${pathPrefix}${this.textureName}_height.png`);
        const specularMap: THREE.Texture = await ForegroundEntity.loadWithFallback(`${pathPrefix}${this.textureName}_specular.png`);
        const shininessMap: THREE.Texture = await ForegroundEntity.loadWithFallback(`${pathPrefix}${this.textureName}_shininess.png`);
        const hydraulicsMap: THREE.Texture = await ForegroundEntity.loadWithFallback(`${pathPrefix}${this.textureName}_hydraulics.png`);

        // Create the square that faces the camera
        const objectGeometry: THREE.PlaneGeometry = new THREE.PlaneGeometry(albedoMap.image.width, albedoMap.image.height);
        const objectMaterial: THREE.ShaderMaterial = new THREE.ShaderMaterial({
            uniforms: {
                albedoMap: { value: albedoMap },
                normalMap: { value: normalMap },
                heightMap: { value: heightMap },
                specularMap: { value: specularMap },
                shininessMap: { value: shininessMap },
                hydraulicsMap: { value: hydraulicsMap }
            },
            glslVersion: THREE.GLSL3,
            vertexShader: defualtVertexShader,
            fragmentShader: geometryFragmentShader
        });

        return new THREE.Mesh(objectGeometry, objectMaterial);
    }

    protected static async loadWithFallback(url: string): Promise<THREE.Texture> {
        try {
            // Try loading the primary texture
            const texture = await ForegroundEntity.loadTexture(url);
            return texture;
        } catch (error) {
            console.error(`❌ Failed to load texture: ${url}, falling back to default...`);

            // If loading the primary texture fails, load the default texture
            const defaultTextureUrl = `./assets/textures/all_zero.png`;
            console.log(`Attempting to load default texture: ${defaultTextureUrl}`);
            return ForegroundEntity.loadTexture(defaultTextureUrl);
        }
    }

}