// src/core/Entity.ts

import * as THREE from 'three';
import { Vec3 } from '../math/Vec3'

export abstract class Entity {
    
    protected positionWorld: Vec3 | null = null;

    protected textureName: string | null;
    protected mesh: THREE.Mesh | null;

    public constructor(textureName: string | null = null) {
        this.textureName = textureName;

        if (textureName == null) {
            this.textureName = 'default_texture'
        }

        this.mesh = null;
    }

    public async initMesh() {
        this.mesh = await this.createTHREEMesh();
    }

    public getMesh(): THREE.Mesh | null{
        return this.mesh;
    }

    public setPosition(x: number, y: number, z: number) {
        this.positionWorld = new Vec3(x, y, z);
    }


    public getPosition(): Vec3 | null{
        return this.positionWorld;
    }

    protected abstract createTHREEMesh(): Promise<THREE.Mesh>;

    protected static loadTexture(url: string): Promise<THREE.Texture> {

        const textureLoader: THREE.TextureLoader = new THREE.TextureLoader();

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
} 
