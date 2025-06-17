// src/core/ActiveEntity.ts

import { ForegroundEntity } from './ForegroundEntity';

export abstract class ActiveEntity extends ForegroundEntity{

    public isAlive: boolean = true;
    public isCollidable: boolean = false;
    public width: number = 1;  // for simple AABB
    public height: number = 1;

    public syncMeshState() {
        if (this.mesh != null && this.positionWorld) {
            this.mesh.position.x = this.positionWorld!.x;
            this.mesh.position.y = this.positionWorld!.y;
            this.mesh.position.z = this.positionWorld!.z;
        }
    }


    update(dT: number) {
        // Override in subclass
    }


    public checkCollision(other: ActiveEntity): boolean {
        if (this.positionWorld && other.positionWorld) {
            const aMinX = this.positionWorld!.x - this.width / 2;
            const aMaxX = this.positionWorld!.x + this.width / 2;
            const aMinY = this.positionWorld!.y - this.height / 2;
            const aMaxY = this.positionWorld!.y + this.height / 2;

            const bMinX = other.positionWorld!.x - other.width / 2;
            const bMaxX = other.positionWorld!.x + other.width / 2;
            const bMinY = other.positionWorld!.y - other.height / 2;
            const bMaxY = other.positionWorld!.y + other.height / 2;

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