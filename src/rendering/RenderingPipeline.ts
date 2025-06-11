// src/rendering/RenderingPipeline.ts

import * as THREE from 'three';

import { Entity } from '../core/Entity';
import { ForegroundEntity } from '../core/ForegroundEntity';
import { BackgroundEntity } from '../core/BackgroundEntity';

import defaultVertexShader from './shaders/defaultVertex.glsl';
import lightingFragmentShader from './shaders/lightingFragment.glsl';
import compositeFragmentShader from './shaders/compositeFragment.glsl';

export class RenderingPipeline {
    private sceneWidth: number;
    private sceneHeight: number;

    private renderer: THREE.WebGLRenderer;
    private camera: THREE.Camera;

    // Render targets
    private backgroundTarget: THREE.WebGLRenderTarget;
    private gBuffer: THREE.WebGLRenderTarget;
    private lightingTarget: THREE.WebGLRenderTarget;
    private compositeTarget: THREE.WebGLRenderTarget;

    // Scenes
    private backgroundScene: THREE.Scene;
    private geometryScene: THREE.Scene;
    private lightingScene: THREE.Scene;
    private compositeScene: THREE.Scene;
    private screenScene: THREE.Scene;

    // Shader materials
    private lightingMaterial: THREE.ShaderMaterial;
    private compositeMaterial: THREE.ShaderMaterial;

    constructor(
        sceneWidth: number,
        sceneHeight: number
    ) {
        this.sceneWidth = sceneWidth;
        this.sceneHeight = sceneHeight;

        this.renderer = new THREE.WebGLRenderer({ antialias: false, preserveDrawingBuffer: true });
        this.camera = new THREE.OrthographicCamera(
            -this.sceneWidth / 2,
            this.sceneWidth / 2,
            this.sceneHeight / 2,
            -this.sceneHeight / 2,
            0,
            1000
        );


        // Initialize render targets
        this.backgroundTarget = new THREE.WebGLRenderTarget(sceneWidth, sceneHeight);
        this.gBuffer = this.createGBuffer(sceneWidth, sceneHeight);
        this.lightingTarget = new THREE.WebGLRenderTarget(sceneWidth, sceneHeight);
        this.compositeTarget = new THREE.WebGLRenderTarget(sceneWidth, sceneHeight);

        // Initialize scenes
        this.backgroundScene = new THREE.Scene();
        this.geometryScene = new THREE.Scene();
        this.lightingScene = new THREE.Scene();
        this.compositeScene = new THREE.Scene();
        this.screenScene = new THREE.Scene();

        // Placeholder shader materials
        this.lightingMaterial = this.createLightingMaterial();
        this.compositeMaterial = this.createCompositeMaterial();

        // Lighting Quad
        const lightingQuad = new THREE.Mesh(
            new THREE.PlaneGeometry(sceneWidth, sceneHeight),
            this.lightingMaterial
        );
        lightingQuad.position.set(0, 0, -1.0);
        this.lightingScene.add(lightingQuad);

        // Composite Quad
        const compositeQuad = new THREE.Mesh(
            new THREE.PlaneGeometry(sceneWidth, sceneHeight),
            this.compositeMaterial
        );
        this.compositeScene.add(compositeQuad);

        // Screen Quad
        const screenQuad = new THREE.Mesh(
            new THREE.PlaneGeometry(sceneWidth, sceneHeight),
            new THREE.MeshBasicMaterial({
                map: this.compositeTarget.texture,
                transparent: false
            })
        );
        this.screenScene.add(screenQuad);
    }


    public render() {

        // Background Pass
        this.renderer.setRenderTarget(this.backgroundTarget);
        this.renderer.render(this.backgroundScene, this.camera);

        // Geometry Pass
        this.renderer.setRenderTarget(this.gBuffer);
        this.renderer.render(this.geometryScene, this.camera);

        // Lighting Pass
        this.renderer.setRenderTarget(this.lightingTarget);
        this.renderer.render(this.lightingScene, this.camera);

        // Composite Pass
        this.renderer.setRenderTarget(this.compositeTarget);
        this.renderer.render(this.compositeScene, this.camera);

        // Screen Pass
        this.renderer.setRenderTarget(null);
        this.renderer.setSize(window.innerWidth, window.innerHeight);
        this.renderer.render(this.screenScene, this.camera);
    }

    public addEntities(entities: Entity | Entity[]) {

        if (Array.isArray(entities)) {
            entities.forEach(entity => {
                this.addEntity(entity);
            });

        } else {
            this.addEntity(entities);
        }

    }


    public removeEntities(entities: Entity | Entity[]) {

        if (Array.isArray(entities)) {
            entities.forEach(entity => {
                this.removeEntity(entity);
            });

        } else {
            this.removeEntity(entities);
        }

    }

    
    private async addEntity(entity: Entity) {

        if (entity.getMesh() == null) {
            await entity.initMesh();
        }

        if (entity instanceof ForegroundEntity) {
            this.geometryScene.add(entity.getMesh()!);
        } else if (entity instanceof BackgroundEntity) {
            this.backgroundScene.add(entity.getMesh()!);
        }
    }

    
    private removeEntity(entity: Entity) {

        if (entity.getMesh() != null) {

            if (entity instanceof ForegroundEntity) {
                this.geometryScene.remove(entity.getMesh()!);
            } else if (entity instanceof BackgroundEntity) {
                this.backgroundScene.remove(entity.getMesh()!);
            }
        }
    }


    private createGBuffer(width: number, height: number): THREE.WebGLRenderTarget {
        return new THREE.WebGLRenderTarget(width, height, {
            minFilter: THREE.NearestFilter,
            magFilter: THREE.NearestFilter,
            count: 3
        });
    }


    private createLightingMaterial(): THREE.ShaderMaterial {
        return new THREE.ShaderMaterial({
            vertexShader: defaultVertexShader,
            fragmentShader: lightingFragmentShader
        });
    }


    private createCompositeMaterial(): THREE.ShaderMaterial {
        return new THREE.ShaderMaterial({
            vertexShader: defaultVertexShader,
            fragmentShader: compositeFragmentShader
        });
    }


    /**
     * Updates lighting uniforms.
     * (Example usage, pass in light data from game logic.)
     */
    updateLightingUniforms(pointLights: any[], skyLight: any, infiniteLights: any) {
        // Example: this.lightingMaterial.uniforms.pointLights.value = pointLights;
    }


}
