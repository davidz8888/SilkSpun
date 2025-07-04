import * as THREE from 'three';

export class AssetLoader {
    
    static async loadWithFallback(url: string): Promise<THREE.Texture> {

        try {
            // Try loading the primary texture
            const texture = await AssetLoader.loadTexture(url);
            return texture;
        } catch (error) {
            console.log(`❌ Failed to load texture: ${url}, falling back to default...`);

            // If loading the primary texture fails, load the default texture
            const defaultTextureUrl = `./assets/textures/all_zero.png`;
            // console.log(`Attempting to load default texture: ${defaultTextureUrl}`);
            return AssetLoader.loadTexture(defaultTextureUrl);
        }
    }

    static loadTexture(url: string): Promise<THREE.Texture> {

        const textureLoader: THREE.TextureLoader = new THREE.TextureLoader();

        return new Promise((resolve, reject) => {
            textureLoader.load(
                url,
                (texture: THREE.Texture) => {
                    texture.minFilter = THREE.NearestFilter;
                    texture.magFilter = THREE.NearestFilter;
                    // console.log(`✅ Loaded texture successfully: ${url}`);
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