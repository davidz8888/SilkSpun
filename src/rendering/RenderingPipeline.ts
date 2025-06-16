// src/rendering/RenderingPipeline.ts

import * as THREE from 'three';

import { Entity } from '../entities/Entity';
import { ForegroundEntity } from '../entities/ForegroundEntity';
import { BackgroundEntity } from '../entities/BackgroundEntity';
import { SkyLight, skyLight, InfiniteLight, infiniteLights, PointLight, pointLights, updateDayNight, debugDayNight } from '../controller/LightingController';
import { Vec3 } from '../math/Vec3';


import defaultVertexShader from './shaders/defaultVertex.glsl';
import lightingFragmentShader from './shaders/lightingFragment.glsl';
import compositeFragmentShader from './shaders/compositeFragment.glsl';
import { positionWorld } from 'three/tsl';

export class RenderingPipeline {
    private sceneWidth: number;
    private sceneHeight: number;

    private renderer: THREE.WebGLRenderer;
    private camera: THREE.Camera;

    // Materials
    private lightingMaterial: THREE.ShaderMaterial;

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
        this.renderer.setSize(sceneWidth, sceneHeight);
        document.body.appendChild(this.renderer.domElement);

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

        // const pointlightsTHREE: PointLightTHREE[] = RenderingPipeline.convertPointLights(pointLights);

        const pointLightNew: PointLightTHREE = {
            positionWorld: new THREE.Vector3(0),
            color: new THREE.Vector3(1),
            falloff: 10,
            radius: 10
        }

        const debugPointLights: PointLightTHREE[] = [pointLightNew];

        const lightingUniforms = {
            screenWidth: { value: sceneWidth },
            screenHeight: { value: sceneHeight },
            albedoMap: { value: this.gBuffer.textures[0] },
            normalMap: { value: this.gBuffer.textures[1] },
            heightMap: { value: this.gBuffer.textures[2] },
            pointLights: { value: debugPointLights },
            numPointLightsInUse: { value: debugPointLights.length },
            skyLight: { value: RenderingPipeline.convertSkyLight(skyLight) },
            infiniteLights: { value: RenderingPipeline.convertInfiniteLights(infiniteLights) }
        };

        this.lightingMaterial = new THREE.ShaderMaterial({
            uniforms: lightingUniforms,
            glslVersion: THREE.GLSL3,
            vertexShader: defaultVertexShader,
            fragmentShader: lightingFragmentShader,
        });

        const lightingQuad: THREE.Mesh = new THREE.Mesh(new THREE.PlaneGeometry(sceneWidth, sceneHeight), this.lightingMaterial);
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

        // debugDayNight();
        updateDayNight();

        // Background Pass
        this.renderer.setRenderTarget(this.backgroundTarget);
        this.renderer.render(this.backgroundScene, this.camera);

        // Geometry Pass
        this.renderer.setRenderTarget(this.gBuffer);
        this.renderer.render(this.geometryScene, this.camera);

        // Lighting Pass
        // Update light uniforms explicitly each frame
        // this.lightingMaterial.uniforms.pointLights.value = ;
        // this.lightingMaterial.uniforms.numPointLightsInUse.value = pointLights.length;
        // this.lightingMaterial.uniforms.skyLight.value = RenderingPipeline.convertSkyLight(skyLight);
        // this.lightingMaterial.uniforms.infiniteLights.value = RenderingPipeline.convertInfiniteLights(infiniteLights);
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
    
    public addLight() {

    }


    
    private static convertPointLights(pointlights: PointLight[]): PointLightTHREE[] {
        return pointlights.map(pointLight => ({
            positionWorld: RenderingPipeline.convertToThreeVec3(pointLight.positionWorld),
            color: RenderingPipeline.convertToThreeVec3(pointLight.color),
            falloff: pointLight.falloff,
            radius: pointLight.radius,
        }));
    }

    private static convertInfiniteLights(infiniteLights: InfiniteLight[]): InfiniteLightTHREE[] {
        return infiniteLights.map(infiniteLight => ({
            direction: RenderingPipeline.convertToThreeVec3(infiniteLight.direction),
            color: RenderingPipeline.convertToThreeVec3(infiniteLight.color),
            shadowDistance: infiniteLight.shadowDistance,
        }));
    }

    private static convertSkyLight(skyLight: SkyLight): SkyLightTHREE {
        return {
            color: RenderingPipeline.convertToThreeVec3(skyLight.color),
            shadowDistance: skyLight.shadowDistance
        }
    }

    private static convertToThreeVec3(v: Vec3): THREE.Vector3 {
        return new THREE.Vector3(v.x, v.y, v.z);
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


interface PointLightTHREE {
    positionWorld: THREE.Vector3,
    color: THREE.Vector3,
    falloff: number,
    radius: number;
}

interface InfiniteLightTHREE {
    direction: THREE.Vector3,
    color: THREE.Vector3,
    shadowDistance: number
}

interface SkyLightTHREE {
    color: THREE.Vector3,
    shadowDistance: number
}