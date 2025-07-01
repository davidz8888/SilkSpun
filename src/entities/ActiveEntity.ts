import { ForegroundEntity } from './ForegroundEntity';
import { Vec3 } from '../math/Vec3';

export abstract class ActiveEntity extends ForegroundEntity{

    public isAlive: boolean = true;
    public isCollidable: boolean = false;
    public width: number = 1;  // for simple AABB
    public height: number = 1;
    private velocity: Vec3 = new Vec3(0.0, 0.0, 0.0);

    syncMeshState() {
        
        if (this.solidMesh != null) {
            this.solidMesh.position.x = this.positionWorld!.x;
            this.solidMesh.position.y = this.positionWorld!.y;
            this.solidMesh.position.z = this.positionWorld!.z;
        }

        if (this.fluidMesh != null) {
            this.fluidMesh.position.x = this.positionWorld!.x;
            this.fluidMesh.position.y = this.positionWorld!.y;
            this.fluidMesh.position.z = this.positionWorld!.z;
        }
    }


    update(dT: number) {
        // Override in subclass
    }


    checkCollision(other: ActiveEntity): boolean {
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


    onCollision(other: ActiveEntity) {
        // Override in subclass for custom collision behavior
    }


    protected getVelocity(): Vec3 {
        return this.velocity;
    }  

    protected getDrag(): number {
        return 1.0;
    }
    
}