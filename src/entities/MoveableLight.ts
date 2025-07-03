import { ActiveEntity } from './ActiveEntity';
import { InputController } from '../controller/InputController';
import { PointLight, LightingController } from '../controller/LightingController';
import { Vec3 } from '../math/Vec3';
import { Vec2 } from '../math/Vec2';
import { RenderingPipeline } from '../rendering/RenderingPipeline';

export class MoveableLight extends ActiveEntity {
    private moveSpeed: number = 2;
    private pointLight: PointLight | null = null;
    private isDragging: boolean = false;
    private dragStartPosition: Vec2 | null = null;
    private lastMousePosition: Vec2 | null = null;

    // Keep references for deregistration if needed
    private mouseDownHandler = (e: MouseEvent) => this.onMouseDown(e);
    private mouseMoveHandler = (e: MouseEvent) => this.onMouseMove(e);
    private mouseUpHandler = () => this.onMouseUp();

    constructor(textureName: string | null = null) {
        super(textureName);
        this.setupMouseEvents();
    }

    override initMesh(pipeline: RenderingPipeline) {
        this.createPointLight(new Vec3(1.0, 0.5, 0.2), 0.2, 50);
        return super.initMesh(pipeline);
    }

    override setPosition(x: number, y: number, z: number): void {
        super.setPosition(x, y, z);
        this.setPointLightPosition(new Vec3(x, y, z));
    }

    private createPointLight(color: Vec3, falloff: number, radius: number) {
        const lightPosition: Vec3 = this.positionWorld.clone();

        this.pointLight = {
            positionWorld: lightPosition,
            color: color,
            falloff: falloff,
            radius: radius,
        };
        LightingController.addPointLight(this.pointLight);
    }

    private setPointLightPosition(positionWorld: Vec3) {
        if (this.pointLight) {
            const lightPosition: Vec3 = this.positionWorld.clone();
            this.pointLight.positionWorld = lightPosition;
        }
    }

    public override update(dT: number): void {
        if (!this.positionWorld) return;

        // Handle movement via keys
        const moveVec = new Vec3();
        if (InputController.isKeyDown('w')) moveVec.y += this.moveSpeed;
        if (InputController.isKeyDown('s')) moveVec.y -= this.moveSpeed;
        if (InputController.isKeyDown('a')) moveVec.x -= this.moveSpeed;
        if (InputController.isKeyDown('d')) moveVec.x += this.moveSpeed;

        this.positionWorld.add(moveVec);
        this.pointLight!.positionWorld.add(moveVec);

        // Handle dragging
        if (this.isDragging && this.lastMousePosition) {
            const dx = this.lastMousePosition.x - this.positionWorld.x;
            const dy = this.lastMousePosition.y - this.positionWorld.y;
            const lightMove = new Vec2(dx / 4, dy / 4);

            this.positionWorld.addVec2(lightMove);
            this.pointLight!.positionWorld.addVec2(lightMove);
        }
    }

    private setupMouseEvents() {
        InputController.addMouseDownCallback(this.mouseDownHandler);
        InputController.addMouseMoveCallback(this.mouseMoveHandler);
        InputController.addMouseUpCallback(this.mouseUpHandler);
    }

    private onMouseDown(e: MouseEvent) {
        const mousePos = InputController.getMousePosition();
        if (!mousePos) return;

        if (this.isMouseOverLight(mousePos)) {
            this.isDragging = true;
            this.dragStartPosition = new Vec2(this.positionWorld.x, this.positionWorld.y);
            this.lastMousePosition = mousePos;
        }
    }

    private onMouseMove(e: MouseEvent) {
        const mousePos = InputController.getMousePosition();
        if (!this.isDragging || !mousePos) return;

        this.lastMousePosition = mousePos;
    }

    private onMouseUp() {
        this.isDragging = false;
        this.dragStartPosition = null;
        this.lastMousePosition = null;
    }

    private isMouseOverLight(mousePos: Vec2): boolean {
        const lightPos = new Vec2(this.positionWorld.x, this.positionWorld.y);
        const dist = mousePos.clone().sub(lightPos);
        return dist.length() <= 50; // Threshold for dragging
    }
}
