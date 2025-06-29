// src/rendering/RenderingPipeline.ts

import * as THREE from 'three';

import { Entity } from '../entities/Entity';
import { ForegroundEntity } from '../entities/ForegroundEntity';
import { BackgroundEntity } from '../entities/BackgroundEntity';
import { LightingController, PointLight, InfiniteLight, SkyLight } from '../controller/LightingController';
import { Vec3 } from '../math/Vec3';
import { SkySampler } from './SkySampler';


import defaultVertexShader from './shaders/defaultVertex.glsl';
import lightingFragmentShader from './shaders/lightingFragment.glsl';
import hydraulicsFragmentShader from './shaders/hydraulicsFragment.glsl';
import advectionFragmentShader from './shaders/advectionFragment.glsl';
import divergenceFragmentShader from './shaders/divergenceFragment.glsl';
import pressureFragmentShader from './shaders/pressureFragment.glsl';
import projectionFragmentShader from './shaders/projectionFragment.glsl';
import compositeFragmentShader from './shaders/compositeFragment.glsl';

export class RenderingPipeline {
    private sceneWidth: number;
    private sceneHeight: number;

    private renderer: THREE.WebGLRenderer;
    private camera: THREE.Camera;

    private pointLights: PointLight[];
    private pointLightsTHREE: any[];

    private infiniteLights: InfiniteLight[];
    private infiniteLightsTHREE: any[];

    private skyLight: SkyLight;
    private skyLightDirections: THREE.Vector3[];

    private lightingMaterial: THREE.ShaderMaterial;
    private hydraulicsMaterial: THREE.ShaderMaterial;
    private advectionMaterial: THREE.ShaderMaterial;
    private divergenceMaterial: THREE.ShaderMaterial;
    private pressureMaterial: THREE.ShaderMaterial;
    private projectionMaterial: THREE.ShaderMaterial;

    private backgroundTarget: THREE.WebGLRenderTarget;
    private gBuffer: THREE.WebGLRenderTarget;
    private lightingTarget: THREE.WebGLRenderTarget;
    private hydraulicsTarget: THREE.WebGLRenderTarget;
    private advectionTarget: THREE.WebGLRenderTarget;
    private divergenceTarget: THREE.WebGLRenderTarget;
    private pressureTargetA: THREE.WebGLRenderTarget;
    private pressureTargetB: THREE.WebGLRenderTarget;
    private projectionTarget: THREE.WebGLRenderTarget;
    private compositeTarget: THREE.WebGLRenderTarget;

    private backgroundScene: THREE.Scene;
    private terrainScene: THREE.Scene;
    private lightingScene: THREE.Scene;
    private hydraulicsScene: THREE.Scene;
    private advectionScene: THREE.Scene;
    private divergenceScene: THREE.Scene;
    private pressureScene: THREE.Scene;
    private projectionScene: THREE.Scene;
    private compositeScene: THREE.Scene;
    private screenScene: THREE.Scene;

    constructor(
        sceneWidth: number,
        sceneHeight: number
    ) {
        this.sceneWidth = sceneWidth;
        this.sceneHeight = sceneHeight;

        this.renderer = new THREE.WebGLRenderer({ antialias: false, preserveDrawingBuffer: true });
        this.renderer.autoClear = false;
        this.renderer.setSize(sceneWidth, sceneHeight);
        this.renderer.toneMapping = THREE.NoToneMapping;
        document.body.appendChild(this.renderer.domElement);

        this.camera = new THREE.OrthographicCamera(
            -this.sceneWidth / 2,
            this.sceneWidth / 2,
            this.sceneHeight / 2,
            -this.sceneHeight / 2,
            0,
            100
        );

        this.backgroundTarget = this.createFloatMRT(sceneWidth, sceneHeight, 1);
        this.gBuffer = this.createFloatMRT(sceneWidth, sceneHeight, 7);
        this.lightingTarget = this.createFloatMRT(sceneWidth, sceneHeight, 1);
        this.hydraulicsTarget = this.createFloatMRT(sceneWidth, sceneHeight, 2);
        this.advectionTarget = this.createFloatMRT(sceneWidth, sceneHeight, 2);
        this.divergenceTarget = this.createFloatMRT(sceneWidth, sceneHeight, 1);
        this.pressureTargetA = this.createFloatMRT(sceneWidth, sceneHeight, 1);
        this.pressureTargetB = this.createFloatMRT(sceneWidth, sceneHeight, 1);
        this.projectionTarget = this.createFloatMRT(sceneWidth, sceneHeight, 2);
        this.compositeTarget = this.createFloatMRT(sceneWidth, sceneHeight, 1);

        this.backgroundScene = new THREE.Scene();
        this.terrainScene = new THREE.Scene();
        this.lightingScene = new THREE.Scene();
        this.hydraulicsScene = new THREE.Scene();
        this.advectionScene = new THREE.Scene();
        this.divergenceScene = new THREE.Scene();
        this.pressureScene = new THREE.Scene();
        this.projectionScene = new THREE.Scene();
        this.compositeScene = new THREE.Scene();
        this.screenScene = new THREE.Scene();

        this.pointLights = LightingController.getPointLights();
        console.log(this.pointLights);
        this.pointLightsTHREE = RenderingPipeline.convertPointLights(this.pointLights);
        RenderingPipeline.padPointLights(this.pointLightsTHREE);

        this.infiniteLights = LightingController.getInfiniteLights();
        this.infiniteLightsTHREE = RenderingPipeline.convertInfiniteLights(this.infiniteLights);
        RenderingPipeline.padInfiniteLights(this.infiniteLightsTHREE);

        this.skyLight = LightingController.getSkyLight();
        this.skyLightDirections = SkySampler.generateSkySamples(100);

        const lightingUniforms = {
            screenWidth: { value: sceneWidth },
            screenHeight: { value: sceneHeight },
            albedoMap: { value: this.gBuffer.textures[0] },
            normalMap: { value: this.gBuffer.textures[1] },
            heightMap: { value: this.gBuffer.textures[2] },
            specularMap: { value: this.gBuffer.textures[3] },
            shininessMap: { value: this.gBuffer.textures[4] },
            pointLights: { value: this.pointLightsTHREE },
            numPointLightsInUse: { value: this.pointLights.length },
            skyLight: { value: RenderingPipeline.convertSkyLight(this.skyLight) },
            skyLightDirections: { value: this.skyLightDirections },
            infiniteLights: { value: this.infiniteLightsTHREE },
            numInfiniteLightsInUse: { value: this.infiniteLights.length }
        };

        this.lightingMaterial = new THREE.ShaderMaterial({
            uniforms: lightingUniforms,
            glslVersion: THREE.GLSL3,
            vertexShader: defaultVertexShader,
            fragmentShader: lightingFragmentShader,
        });

        const lightingQuad: THREE.Mesh = new THREE.Mesh(new THREE.PlaneGeometry(sceneWidth, sceneHeight), this.lightingMaterial);
        this.lightingScene.add(lightingQuad);

        const hydraulicsUniforms = {
            screenWidth: { value: sceneWidth },
            screenHeight: { value: sceneHeight },
            hydraulicsMap: { value: this.gBuffer.textures[5] },
            emissionsMap: { value: this.gBuffer.textures[6] },
            velocityMap: { value: this.projectionTarget.textures[0] },
            matterMap: { value: this.projectionTarget.textures[1] }
        }

        this.hydraulicsMaterial = new THREE.ShaderMaterial({
            uniforms: hydraulicsUniforms,
            glslVersion: THREE.GLSL3,
            vertexShader: defaultVertexShader,
            fragmentShader: hydraulicsFragmentShader
        });

        const hydraulicsQuad: THREE.Mesh = new THREE.Mesh(new THREE.PlaneGeometry(sceneWidth, sceneHeight), this.hydraulicsMaterial);
        this.hydraulicsScene.add(hydraulicsQuad);


        const advectionUniforms = {
            screenWidth: { value: sceneWidth },
            screenHeight: { value: sceneHeight },
            hydraulicsMap: { value: this.gBuffer.textures[5] },
            velocityMap: { value: this.hydraulicsTarget.textures[0] },
            matterMap: { value: this.hydraulicsTarget.textures[1] }
        }

        this.advectionMaterial = new THREE.ShaderMaterial({
            uniforms: advectionUniforms,
            glslVersion: THREE.GLSL3,
            vertexShader: defaultVertexShader,
            fragmentShader: advectionFragmentShader
        });

        const advectionQuad: THREE.Mesh = new THREE.Mesh(new THREE.PlaneGeometry(sceneWidth, sceneHeight), this.advectionMaterial);
        this.advectionScene.add(advectionQuad);

        const divergenceUniforms = {
            screenWidth: { value: sceneWidth },
            screenHeight: { value: sceneHeight },
            hydraulicsMap: { value: this.gBuffer.textures[5] },
            velocityMap: { value: this.advectionTarget.textures[0] },
            matterMap: { value: this.advectionTarget.textures[1] }
        }

        this.divergenceMaterial = new THREE.ShaderMaterial({
            uniforms: divergenceUniforms,
            glslVersion: THREE.GLSL3,
            vertexShader: defaultVertexShader,
            fragmentShader: divergenceFragmentShader
        });

        const divergenceQuad: THREE.Mesh = new THREE.Mesh(new THREE.PlaneGeometry(sceneWidth, sceneHeight), this.divergenceMaterial);
        this.divergenceScene.add(divergenceQuad);


        const pressureUniform = {
            screenWidth: { value: sceneWidth },
            screenHeight: { value: sceneHeight },
            hydraulicsMap: { value: this.gBuffer.textures[5] },
            divergenceMap: { value: this.divergenceTarget.texture },
            pressureMap: { value: this.pressureTargetB.texture }
        }

        this.pressureMaterial = new THREE.ShaderMaterial({
            uniforms: pressureUniform,
            glslVersion: THREE.GLSL3,
            vertexShader: defaultVertexShader,
            fragmentShader: pressureFragmentShader,
        });

        const pressureQuad: THREE.Mesh = new THREE.Mesh(new THREE.PlaneGeometry(sceneWidth, sceneHeight), this.pressureMaterial);
        this.pressureScene.add(pressureQuad);

        const projectionUniforms = {
            screenWidth: { value: sceneWidth },
            screenHeight: { value: sceneHeight },
            hydraulicsMap: { value: this.gBuffer.textures[5] },
            velocityMap: { value: this.advectionTarget.textures[0] },
            matterMap: { value: this.advectionTarget.textures[1] },
            pressureMap: { value: this.pressureTargetA.textures[0] }
        }

        this.projectionMaterial = new THREE.ShaderMaterial({
            uniforms: projectionUniforms,
            glslVersion: THREE.GLSL3,
            vertexShader: defaultVertexShader,
            fragmentShader: projectionFragmentShader
        });

        const projectionQuad: THREE.Mesh = new THREE.Mesh(new THREE.PlaneGeometry(sceneWidth, sceneHeight), this.projectionMaterial);
        this.projectionScene.add(projectionQuad);

        const compositeUniforms = {
            screenWidth: { value: sceneWidth },
            screenHeight: { value: sceneHeight },
            background: { value: this.backgroundTarget.texture },
            foreground: { value: this.lightingTarget.texture },
            hydraulicsMap: { value: this.hydraulicsTarget.texture },
            velocityMap: { value: this.projectionTarget.textures[0] },
            matterMap: { value: this.projectionTarget.textures[1] },
            divergenceMap : { value: this.divergenceTarget.texture },
            pressureMapA: { value: this.pressureTargetA.texture },
            pressureMapB: { value: this.pressureTargetB.texture }
        };

        const compositeMaterial: THREE.ShaderMaterial = new THREE.ShaderMaterial({
            uniforms: compositeUniforms,
            glslVersion: THREE.GLSL3,
            vertexShader: defaultVertexShader,
            fragmentShader: compositeFragmentShader,
        });

        const compositeQuad: THREE.Mesh = new THREE.Mesh(new THREE.PlaneGeometry(sceneWidth, sceneHeight), compositeMaterial);
        this.compositeScene.add(compositeQuad);

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

        // LightingController.updateDayNight();

        // Background Pass
        this.renderer.setRenderTarget(this.backgroundTarget);
        this.renderer.render(this.backgroundScene, this.camera);

        // Terrain Pass
        this.renderer.setRenderTarget(this.gBuffer);
        this.renderer.render(this.terrainScene, this.camera);

        // Lighting Pass
        // Update light uniforms explicitly each frame

        this.pointLights = LightingController.getPointLights();
        this.pointLightsTHREE = RenderingPipeline.convertPointLights(this.pointLights);
        RenderingPipeline.padPointLights(this.pointLightsTHREE);
        this.lightingMaterial.uniforms.pointLights.value = this.pointLightsTHREE;
        this.lightingMaterial.uniforms.numPointLightsInUse.value = this.pointLights.length;
        this.lightingMaterial.uniforms.skyLight.value = RenderingPipeline.convertSkyLight(this.skyLight);

        this.infiniteLights = LightingController.getInfiniteLights();
        this.infiniteLightsTHREE = RenderingPipeline.convertInfiniteLights(this.infiniteLights);
        RenderingPipeline.padInfiniteLights(this.infiniteLightsTHREE)
        this.lightingMaterial.uniforms.infiniteLights.value = this.infiniteLightsTHREE;
        this.lightingMaterial.uniforms.numInfiniteLightsInUse.value = this.infiniteLights.length;

        this.renderer.setRenderTarget(this.lightingTarget);
        this.renderer.render(this.lightingScene, this.camera);

        this.renderer.setRenderTarget(this.hydraulicsTarget);
        this.renderer.render(this.hydraulicsScene, this.camera);

        this.renderer.setRenderTarget(this.advectionTarget);
        this.renderer.render(this.advectionScene, this.camera);

        this.renderer.setRenderTarget(this.divergenceTarget);
        this.renderer.render(this.divergenceScene, this.camera);

        this.renderer.setRenderTarget(this.pressureTargetA);
        this.renderer.clear();

        this.renderer.setRenderTarget(this.pressureTargetB);
        this.renderer.clear();

        this.renderer.setRenderTarget(this.pressureTargetA);
        this.renderer.render(this.pressureScene, this.camera);


        const NUM_ITERATIONS = 500;

        for (let i = 0; i < NUM_ITERATIONS; i++) {

            this.pressureMaterial.uniforms.pressureMap.value = this.pressureTargetA.texture;
            this.renderer.setRenderTarget(this.pressureTargetB);
            this.renderer.render(this.pressureScene, this.camera);

            this.pressureMaterial.uniforms.pressureMap.value = this.pressureTargetB.texture;
            this.renderer.setRenderTarget(this.pressureTargetA);
            this.renderer.render(this.pressureScene, this.camera);

        }

        this.renderer.setRenderTarget(this.projectionTarget);
        this.renderer.render(this.projectionScene, this.camera);

        this.divergenceMaterial.uniforms.velocityMap.value = this.projectionTarget.textures[0];
        this.renderer.setRenderTarget(this.divergenceTarget);
        this.renderer.render(this.divergenceScene, this.camera);

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
            this.terrainScene.add(entity.getMesh()!);
            console.log(entity.getMesh()!.position)
        } else if (entity instanceof BackgroundEntity) {
            this.backgroundScene.add(entity.getMesh()!);
        }
    }

    private removeEntity(entity: Entity) {

        if (entity.getMesh() != null) {

            if (entity instanceof ForegroundEntity) {
                this.terrainScene.remove(entity.getMesh()!);
            } else if (entity instanceof BackgroundEntity) {
                this.backgroundScene.remove(entity.getMesh()!);
            }
        }
    }


    private static convertPointLights(pointLights: PointLight[]): any[] {
        return pointLights.map(pointLight => ({
            positionWorld: RenderingPipeline.convertToThreeVec3(pointLight.positionWorld),
            color: RenderingPipeline.convertToThreeVec3(pointLight.color),
            falloff: pointLight.falloff,
            radius: pointLight.radius,
        }));
    }

    private static padPointLights(pointLights: any[]) {
        const defaultLight = {
            positionWorld: new THREE.Vector3(0, 0, 0),
            color: new THREE.Vector3(0, 0, 0),
            falloff: 1,
            radius: 0
        };

        const MAX_POINTLIGHTS = 100

        while (pointLights.length < MAX_POINTLIGHTS) {
            pointLights.push(defaultLight);
        }
    }

    private static convertInfiniteLights(infiniteLights: InfiniteLight[]): any[] {
        return infiniteLights.map(infiniteLight => ({
            direction: RenderingPipeline.convertToThreeVec3(infiniteLight.direction),
            color: RenderingPipeline.convertToThreeVec3(infiniteLight.color),
            shadowDistance: infiniteLight.shadowDistance,
        }));
    }

    private static padInfiniteLights(infiniteLights: any[]) {
        const defaultLight = {
            direction: new THREE.Vector3(0, 0, 0),
            color: new THREE.Vector3(0, 0, 0),
            shadowDistance: 0
        };

        const MAX_INFINITELIGHTS = 10

        while (infiniteLights.length < MAX_INFINITELIGHTS) {
            infiniteLights.push(defaultLight);
        }
    }

    private static convertSkyLight(skyLight: SkyLight): any {
        return {
            color: RenderingPipeline.convertToThreeVec3(skyLight.color),
            shadowDistance: skyLight.shadowDistance
        }
    }

    private static convertToThreeVec3(v: Vec3): THREE.Vector3 {
        return new THREE.Vector3(v.x, v.y, v.z);
    }


    private createFloatMRT(width: number, height: number, numTargets: number): THREE.WebGLRenderTarget {
        return new THREE.WebGLRenderTarget(width, height, {
            type: THREE.FloatType,
            minFilter: THREE.NearestFilter,
            magFilter: THREE.NearestFilter,
            count: numTargets,
        });
    }

}

