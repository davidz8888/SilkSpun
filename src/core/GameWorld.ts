import { Scene } from './Scene';
import { Layer } from './Layer';
import { Entity } from '../entities/Entity';
import { ActiveEntity } from '../entities/ActiveEntity';

export class GameWorld {
    private layers: Layer[] = [];

    constructor() { }

    public loadScene(scene: Scene) {

        this.layers = scene.getLayers();
    }

    public update(deltaTime: number) {
        for (const layer of this.layers) {
            layer.update(deltaTime);
        }
    }

    public syncMeshState() {

        for (const layer of this.layers) {
            layer.syncMeshState();
        }

    }

    public getAllEntities(): Entity[] {

        const allEntities: Entity[] = [];

        for (const layer of this.layers) {
            allEntities.push(...layer.getEntities());
        }

        return allEntities
    }

    public getAllActiveEntities(): ActiveEntity[] {

        const allActiveEntities: ActiveEntity[] = [];

        for (const layer of this.layers) {
            allActiveEntities.push(...layer.getActiveEntities());
        }

        return allActiveEntities;
    }


    public handleCollisions() {
        const activeEntities = this.getAllActiveEntities();

        for (let i = 0; i < activeEntities.length; i++) {
            for (let j = i + 1; j < activeEntities.length; j++) {
                const a = activeEntities[i];
                const b = activeEntities[j];

                if (a.checkCollision(b)) {
                    a.onCollision(b);
                    b.onCollision(a);
                }
            }
        }
    }
}
