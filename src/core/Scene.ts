import { GameWorld } from './GameWorld';
import { Layer } from './Layer';

export abstract class Scene {

    private gameWorld: GameWorld;
    private layers: Layer[];

    constructor(gameWorld: GameWorld) {
        this.gameWorld = gameWorld;
        this.layers = [];
    }


    public addLayer(layer: Layer) {
        this.layers.push(layer);
    }

    public removeLayer(layer: Layer) {

        const index = this.layers.indexOf(layer);
        if (index !== -1) {
            this.layers.splice(index, 1);
        } else {
            console.warn(`Layer not found:`, layer);
        }
        
    }

    public getLayers(): Layer[] {
        return this.layers;
    }
}
