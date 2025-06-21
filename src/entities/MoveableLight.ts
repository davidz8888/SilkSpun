// src/core/MoveableLight.ts

import { ActiveEntity } from './ActiveEntity';
import * as THREE from 'three';
import { InputController } from '../controller/InputController';
import { PointLight, addPointLight } from '../controller/LightingController';
import { Vec3 } from '../math/Vec3';



export class MoveableLight extends ActiveEntity {

  private moveSpeed: number = 1;
  private input: InputController | null = null;
  private pointLight: PointLight | null = null;

  constructor(textureName: string | null = null) {

    super(textureName);

  }

  public override initMesh() {
    this.createPointLight(new Vec3(1.0, 1.0, 1.0), 0.0, 200);
    return super.initMesh();
  }

  public setInputController(controller: InputController) {
    this.input = controller;
  }


  public override setPosition(x: number, y: number, z: number): void {
    super.setPosition(x, y, z);
    this.setPointLightPosition(new Vec3(x, y, z));
  }

  private createPointLight(color: Vec3, falloff: number, radius: number) {

    this.pointLight = {
      positionWorld: this.positionWorld!,
      color: color,
      falloff: falloff,
      radius: radius,
    }
    addPointLight(this.pointLight);
  }


  private setPointLightPosition(positionWorld: Vec3) {
    if (this.pointLight) {
      this.pointLight.positionWorld = positionWorld;
    }
  }

  public override update(deltaTime: number): void {

    if (!this.positionWorld) return;
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
