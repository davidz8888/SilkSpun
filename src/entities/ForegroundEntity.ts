// src/core/ForegroundEntity.ts

import * as THREE from 'three';
import { Entity } from './Entity';
import defaultVertexShader from '../rendering/shaders/defaultVertex.glsl';
import terrainFragmentShader from '../rendering/shaders/terrainFragment.glsl';
import hydraulicsFragmentShader from '../rendering/shaders/hydraulicFragment.glsl';
import { Vec3 } from '../math/Vec3';
import { RenderingPipeline } from '../rendering/RenderingPipeline';

export abstract class ForegroundEntity extends Entity {

    protected static FLUID_Z = -20;

    protected solidMesh: THREE.Mesh | null = null;
    protected fluidMesh: THREE.Mesh | null = null;

    constructor(textureName: string | null = null) {

        super(textureName);
    }

    async initMesh(pipeline: RenderingPipeline) {

        this.solidMesh = await pipeline.createSolidMesh(this.textureName);
        this.solidMesh.position.set(this.positionWorld.x, this.positionWorld.y, this.positionWorld.z);

        this.fluidMesh = await pipeline.createFluidMesh(this.textureName);
        this.fluidMesh.position.set(this.positionWorld.x, this.positionWorld.y, this.positionWorld.z);
    }

    public getSolidMesh(): THREE.Mesh | null {
        return this.solidMesh;
    }

    public getFluidMesh(): THREE.Mesh | null {
        return this.fluidMesh;
    }

    protected getVelocity(): Vec3 {
        return new Vec3(0.0, 0.0, 0.0);
    }

    protected getDrag(): number {
        return 0.0;
    }
}