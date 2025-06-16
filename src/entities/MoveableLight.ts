// src/core/MoveableLight.ts

import { ActiveEntity } from './ActiveEntity';
import * as THREE from 'three';
import { InputController } from '../controller/InputController';
import { PointLight, addPointLight } from '../controller/LightingController';
import { Vec3 } from '../math/Vec3';



export class PlayerLightEntity extends ActiveEntity {

  private moveSpeed: number = 50;
  private input: InputController | null = null;
  private pointLight: PointLight;

  constructor() {

    super();

    this.pointLight = {
      positionWorld: new Vec3(0, 0, 0),
      color: new Vec3(1.0, 0.9, 0.6),
      falloff: 1.0,
      radius: 150.0,
    };

  }

  setInputController(controller: InputController) {
    this.input = controller;
  }

  update(dt: number): void {

    if (!this.input) return;

    const moveVec = new Vec3();

    if (this.input.isKeyDown('w')) moveVec.y += this.moveSpeed;
    if (this.input.isKeyDown('s')) moveVec.y -= this.moveSpeed;
    if (this.input.isKeyDown('a')) moveVec.x -= this.moveSpeed;
    if (this.input.isKeyDown('d')) moveVec.x += this.moveSpeed;


    this.positionWorld.add(moveVec);

    this.pointLight.positionWorld.add(moveVec);
  }

}
