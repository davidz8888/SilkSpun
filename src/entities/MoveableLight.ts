// src/core/MoveableLight.ts

import { ActiveEntity } from './ActiveEntity';
import * as THREE from 'three';
import { InputController } from '../controller/InputController';
import { PointLight, addPointLight } from '../controller/LightingController';
import { Vec3 } from '../math/Vec3';



export class MoveableLight extends ActiveEntity {

  private moveSpeed: number = 50;
  private input: InputController | null = null;
  private pointLight: PointLight | null = null;

  constructor(textureName: string | null = null) {

    super(textureName);

  }

  public setInputController(controller: InputController) {
    this.input = controller;
  }


  public override async initialize(x: number, y: number, z: number) {

    this.pointLight = {
      positionWorld: new Vec3(x, y, z),
      color: new Vec3(1.0, 0.9, 0.6),
      falloff: 1.0,
      radius: 150.0,
    };

    addPointLight(this.pointLight);
  }


  public update(dt: number): void {

    if (!this.initialized) return;
    if (!this.input) return;

    const moveVec = new Vec3();

    if (this.input.isKeyDown('w')) moveVec.y += this.moveSpeed;
    if (this.input.isKeyDown('s')) moveVec.y -= this.moveSpeed;
    if (this.input.isKeyDown('a')) moveVec.x -= this.moveSpeed;
    if (this.input.isKeyDown('d')) moveVec.x += this.moveSpeed;


    this.positionWorld!.add(moveVec);
    this.pointLight!.positionWorld.add(moveVec);
  }

}
