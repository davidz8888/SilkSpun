// src/core/ActiveEntity.ts

import { ForegroundEntity } from './ForegroundEntity';

export abstract class ActiveEntity extends ForegroundEntity{

    public isAlive: boolean = true;
    public isCollidable: boolean = false;
    public width: number = 1;  // for simple AABB
    public height: number = 1;

    public syncMeshState() {
        if (this.mesh != null && this.positionSet) {
            this.mesh.position.x = this.x!;
            this.mesh.position.y = this.y!;
            this.mesh.position.z = this.z!;
        }
    }


    update(deltaTime: number) {
        // Override in subclass
    }


    public checkCollision(other: ActiveEntity): boolean {
        if (this.positionSet && other.positionSet) {
            const aMinX = this.x! - this.width / 2;
            const aMaxX = this.x! + this.width / 2;
            const aMinY = this.y! - this.height / 2;
            const aMaxY = this.y! + this.height / 2;

            const bMinX = other.x! - other.width / 2;
            const bMaxX = other.x! + other.width / 2;
            const bMinY = other.y! - other.height / 2;
            const bMaxY = other.y! + other.height / 2;

            return (
                aMinX < bMaxX &&
                aMaxX > bMinX &&
                aMinY < bMaxY &&
                aMaxY > bMinY
            );

        } else {
            return false;
        }
    }


    public onCollision(other: ActiveEntity) {
        // Override in subclass for custom collision behavior
    }
}