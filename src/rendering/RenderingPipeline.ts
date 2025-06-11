// src/rendering/RenderingPipeline.ts

import * as THREE from 'three';

import { Entity } from '../core/Entity';
import { ForegroundEntity } from '../core/ForegroundEntity';
import { BackgroundEntity } from '../core/BackgroundEntity';
import { skyLight, infiniteLights, pointLights } from '../lightManager';

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

        const lightingUniforms = {
            screenWidth: { value: sceneWidth },
            screenHeight: { value: sceneHeight },
            albedoMap: { value: this.gBuffer.textures[0] },
            normalMap: { value: this.gBuffer.textures[1] },
            heightMap: { value: this.gBuffer.textures[2] },
            pointLights: { value: pointLights },
            numPointLightsInUse: { value: pointLights.length },
            skyLight: { value: skyLight },
            infiniteLights: { value: infiniteLights }
        };

        const lightingMaterial: THREE.ShaderMaterial = new THREE.ShaderMaterial({
            uniforms: lightingUniforms,
            glslVersion: THREE.GLSL3,
            vertexShader: defaultVertexShader,
            fragmentShader: lightingFragmentShader,
        });

        const lightingQuad: THREE.Mesh = new THREE.Mesh(new THREE.PlaneGeometry(sceneWidth, sceneHeight), lightingMaterial);
        this.lightingScene.add(lightingQuad);
        lightingQuad.position.set(0, 0, -1.0);

        // Composite Pass
        const compositeUniforms = {
            screenWidth: { value: sceneWidth },
            screenHeight: { value: sceneHeight },
            background: { value: this.backgroundTarget.texture },
            foreground: { value: this.lightingTarget.texture },
        };

        const compositeMaterial: THREE.ShaderMaterial = new THREE.ShaderMaterial({
            uniforms: compositeUniforms,
            glslVersion: THREE.GLSL3,
            vertexShader: defaultVertexShader,
            fragmentShader: compositeFragmentShader,
        });

        const compositeQuad: THREE.Mesh = new THREE.Mesh(new THREE.PlaneGeometry(sceneWidth, sceneHeight), compositeMaterial);
        this.compositeScene.add(compositeQuad);

        // Screen Pass
        const screenMaterial: THREE.MeshBasicMaterial = new THREE.MeshBasicMaterial({
            map: Object.assign(this.compositeTarget.texture, {
                minFilter: THREE.NearestFilter,
                magFilter: THREE.NearestFilter,
            }),
        });

        const screenQuad: THREE.Mesh = new THREE.Mesh(new THREE.PlaneGeometry(sceneWidth, sceneHeight), screenMaterial);
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


    /**
     * Updates lighting uniforms.
     * (Example usage, pass in light data from game logic.)
     */
    updateLightingUniforms(pointLights: any[], skyLight: any, infiniteLights: any) {
        // Example: this.lightingMaterial.uniforms.pointLights.value = pointLights;
    }


}
