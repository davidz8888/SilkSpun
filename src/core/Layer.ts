// src/core/Layer.ts

import { Entity } from '../entities/Entity';
import { ActiveEntity } from '../entities/ActiveEntity';

export class Layer {

    public name: string;

    public zValue: number;
    private entities: Entity[] = [];
    private activeEntities: ActiveEntity[] = [];

    public constructor(name: string, zValue: number) {
        this.name = name;
        this.zValue = zValue;
    }

    public addEntity(entity: Entity, x: number, y: number) {

        this.entities.push(entity);

        if (entity instanceof ActiveEntity) {
            this.activeEntities.push(entity);
        }

        entity.setPosition(x, y, this.zValue);
    }

    public removeEntity(entity: Entity) {

        const entityIndex = this.entities.indexOf(entity);

        if (entityIndex !== -1) {
            this.entities.splice(entityIndex, 1);
        } else {
            console.warn(`Entity not found:`, entity);
        }

        if (entity instanceof ActiveEntity) {

            const activeIndex = this.activeEntities.indexOf(entity);

            if (activeIndex !== -1) {
                this.activeEntities.splice(activeIndex, 1);
            } else {
                console.warn(`Entity not found:`, entity);
            }
        }
    }

    public getEntities(): Entity[] {
        return this.entities;
    }

    public getActiveEntities(): ActiveEntity[] {
        return this.activeEntities;
    }

    public update(deltaTime: number) {
        for (const entity of this.entities) {
            if (entity instanceof ActiveEntity) {
                entity.update(deltaTime);
            }
        }
    }

    public syncMeshState() {
        for (const entity of this.entities) {
            if (entity instanceof ActiveEntity) {
                entity.syncMeshState();
            }
        }
    }
}