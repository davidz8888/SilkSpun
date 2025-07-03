import { PassiveEntity } from './PassiveEntity';
import { InputController } from '../controller/InputController';
import { PointLight, LightingController } from '../controller/LightingController';
import { Vec3 } from '../math/Vec3';
import { Vec2 } from '../math/Vec2';
import { RenderingPipeline } from '../rendering/RenderingPipeline';

export class Candle extends PassiveEntity {
    private pointLight: PointLight | null = null;
    private color: Vec3 = new Vec3(0.5, 0.1, 0.0);
    private falloff: number = 0.1;
    private radius: number = 200;

    // Keep references for deregistration if needed

    constructor() {
        super('candle');
    }

    override initMesh(pipeline: RenderingPipeline) {
        this.createPointLight(this.color, this.falloff, this.radius);
        return super.initMesh(pipeline);
    }

    override setPosition(x: number, y: number, z: number): void {
        super.setPosition(x, y, z);
        this.setPointLightPosition(new Vec3(x, y, z));
    }

    private createPointLight(color: Vec3, falloff: number, radius: number) {
        const lightPosition: Vec3 = this.positionWorld.clone();
        lightPosition.y += 16;
        lightPosition.z += 15;
        this.pointLight = {
            positionWorld: lightPosition,
            color: color,
            falloff: falloff,
            radius: radius,
        };
        LightingController.addPointLight(this.pointLight);
    }

    private setPointLightPosition(positionWorld: Vec3) {
        const lightPosition: Vec3 = this.positionWorld.clone();
        lightPosition.y += 16;
        lightPosition.z += 10;
        if (this.pointLight) {
            this.pointLight.positionWorld = lightPosition;
        }
    }


}
