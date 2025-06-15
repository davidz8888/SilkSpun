// src/core/controllableLight.ts

import { ActiveEntity } from './ActiveEntity';
import * as THREE from 'three';
import { InputController } from '../controller/InputController';


// Shared light data format expected by your deferred shader
export type GPULight = {
  position: THREE.Vector3;
  color: THREE.Vector3;
  intensity: number;
  radius: number;
};

export class PlayerLightEntity extends ActiveEntity {
  private sprite: THREE.Sprite;
  private moveSpeed: number = 50;
  private input: InputController | null = null;
  private lightData: GPULight;

  constructor(initialPosition = new THREE.Vector3(0, 0, 0)) {
    super();

    this.lightData = {
      position: initialPosition.clone(),
      color: new THREE.Vector3(1.0, 0.9, 0.6),
      intensity: 1.0,
      radius: 150.0,
    };

    this.sprite = new THREE.Sprite(new THREE.SpriteMaterial({ color: 0xffeeaa }));
    this.sprite.scale.set(10, 10, 1);

    this.object3D.add(this.sprite);
    this.object3D.position.copy(initialPosition);
  }

  setInputController(controller: InputController) {
    this.input = controller;
  }

  update(dt: number): void {
    if (!this.input) return;

    const moveVec = new THREE.Vector3();

    if (this.input.isKeyDown('w')) moveVec.y += 1;
    if (this.input.isKeyDown('s')) moveVec.y -= 1;
    if (this.input.isKeyDown('a')) moveVec.x -= 1;
    if (this.input.isKeyDown('d')) moveVec.x += 1;
    if (this.input.isKeyDown('q')) moveVec.z += 1;
    if (this.input.isKeyDown('e')) moveVec.z -= 1;

    moveVec.normalize().multiplyScalar(this.moveSpeed * dt);
    this.object3D.position.add(moveVec);

    this.sprite.position.copy(this.object3D.position);
    this.lightData.position.copy(this.object3D.position);
  }

  getLightData(): GPULight {
    return this.lightData;
  }
}
