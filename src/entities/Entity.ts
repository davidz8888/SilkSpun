import * as THREE from 'three';
import { Vec3 } from '../math/Vec3'
import { RenderingPipeline } from '../rendering/RenderingPipeline';

export abstract class Entity {
    
    protected positionWorld: Vec3;

    protected textureName: string;


    constructor(textureName: string | null = null) {

        this.textureName = textureName == null ? 'default_texture' : textureName;
        this.positionWorld = new Vec3(0, 0, 0);

    }

    abstract initMesh(pipeline: RenderingPipeline): void;

    public setPosition(x: number, y: number, z: number) {
        this.positionWorld = new Vec3(x, y, z);
    }

    public getPosition(): Vec3 | null{
        return this.positionWorld;
    }

} 
