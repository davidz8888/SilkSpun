import { ActiveEntity } from './ActiveEntity';
import { InputController } from '../controller/InputController';
import { PointLight, addPointLight } from '../controller/LightingController';
import { Vec3 } from '../math/Vec3';
import { Vec2 } from '../math/Vec2';

export class MoveableLight extends ActiveEntity {
  private moveSpeed: number = 1;
  private input: InputController | null = null;
  private pointLight: PointLight | null = null;
  private isDragging: boolean = false;
  private dragStartPosition: Vec2 | null = null;
  private lastMousePosition: Vec2 | null = null;

  constructor(textureName: string | null = null) {
    super(textureName);
  }

  public override initMesh() {
    this.createPointLight(new Vec3(1.0, 1.0, 1.0), 0.0, 200);
    return super.initMesh();
  }

  public setInputController(controller: InputController) {
    this.input = controller;
    this.setupMouseEvents();
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
    };
    addPointLight(this.pointLight);
  }

  private setPointLightPosition(positionWorld: Vec3) {
    if (this.pointLight) {
      this.pointLight.positionWorld = positionWorld;
    }
  }

  public override update(dT: number): void {
    if (!this.positionWorld || !this.input) return;

    // Handle movement via keys
    const moveVec = new Vec3();
    if (this.input.isKeyDown('w')) moveVec.y += this.moveSpeed;
    if (this.input.isKeyDown('s')) moveVec.y -= this.moveSpeed;
    if (this.input.isKeyDown('a')) moveVec.x -= this.moveSpeed;
    if (this.input.isKeyDown('d')) moveVec.x += this.moveSpeed;

    // Apply key movement
    this.positionWorld!.add(moveVec);
    this.pointLight!.positionWorld.add(moveVec);

    // If dragging, update the light position based on mouse position
    if (this.isDragging && this.lastMousePosition) {
      const mouseDisplacementX = this.lastMousePosition.x - this.positionWorld!.x;
      const mouseDisplacementY = this.lastMousePosition.y - this.positionWorld!.y;

      const lightMove = new Vec2(mouseDisplacementX / 4, mouseDisplacementY / 4);
      this.positionWorld!.addVec2(lightMove);
      this.pointLight!.positionWorld.addVec2(lightMove);
      console.log(lightMove);
    }
  }

  private setupMouseEvents() {
    if (!this.input) return;

    this.input.setMouseDownCallback((e) => this.onMouseDown(e));
    this.input.setMouseMoveCallback((e) => this.onMouseMove(e));
    this.input.setMouseUpCallback(() => this.onMouseUp());
  }

  private onMouseDown(e: MouseEvent) {
    const mousePos = this.input?.getMousePosition(); // Now returns Vec2
    if (!mousePos) return;

    // Check if the mouse is over the light (or near it)
    if (this.isMouseOverLight(mousePos)) {

      this.isDragging = true;
      this.dragStartPosition = new Vec2(this.positionWorld?.x, this.positionWorld?.y) ?? new Vec2(0, 0);
      this.lastMousePosition = mousePos;
    }
  }

  private onMouseMove(e: MouseEvent) {
    const mousePos = this.input?.getMousePosition(); 
    if (!this.isDragging || !mousePos) return;

    this.lastMousePosition = mousePos;
  }

  private onMouseUp() {
    this.isDragging = false;
    this.dragStartPosition = null;
    this.lastMousePosition = null;
  }

  private isMouseOverLight(mousePos: Vec2): boolean {
    // You can define a radius or threshold to check if the mouse is near the light
    const lightPosition = new Vec2(this.positionWorld!.x, this.positionWorld!.y);
    const distance = mousePos.clone().sub(lightPosition);
    const distanceThreshold = 50; // Adjust this threshold for how close the mouse needs to be to interact with the light
    console.log(mousePos)
    return distance.length() <= distanceThreshold;
  }
}
