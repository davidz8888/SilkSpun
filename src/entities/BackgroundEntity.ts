// src/core/BackgroundEntity.ts

import * as THREE from 'three';
import { Entity } from './Entity';
import defualtVertexShader from '../rendering/shaders/defaultVertex.glsl';
import backgroundFragmentShader from '../rendering/shaders/backgroundFragment.glsl';
import { RenderingPipeline } from '../rendering/RenderingPipeline';

export class BackgroundEntity extends Entity {

    private mesh: THREE.Mesh | null = null;

    constructor(textureName: string | null) {
        
        super(textureName);

    }

    async initMesh(pipeline: RenderingPipeline){
        this.mesh = await pipeline.createSimpleMesh(this.textureName);
    }

    getMesh(): THREE.Mesh | null {
        return this.mesh
    }
}