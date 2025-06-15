// src/core/Entity.ts

import * as THREE from 'three';

export abstract class Entity {
    protected x: number | null;
    protected y: number | null;
    protected z: number | null;
    protected positionSet: boolean;

    protected textureName: string | null;
    protected mesh: THREE.Mesh | null;

    public constructor(textureName: string | null = null) {
        this.x = null;
        this.y = null;
        this.z = null;
        this.positionSet = false;

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
        this.x = x;
        this.y = y;
        this.z = z;
        this.positionSet = true;
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
