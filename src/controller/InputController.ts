import { Vec2 } from "../math/Vec2";

export class InputController {
  private keys: Set<string>;
  private mouseButtons: Set<number>;
  private mousePosition: Vec2;
  private mouseDownCallback: ((e: MouseEvent) => void) | null = null;
  private mouseMoveCallback: ((e: MouseEvent) => void) | null = null;
  private mouseUpCallback: (() => void) | null = null;

  constructor() {
    this.keys = new Set<string>();
    this.mouseButtons = new Set<number>();
    this.mousePosition = new Vec2(0, 0);

    window.addEventListener('keydown', (e) => this.keys.add(e.key.toLowerCase()));
    window.addEventListener('keyup', (e) => this.keys.delete(e.key.toLowerCase()));
    window.addEventListener('mousedown', (e) => this.mouseDownCallback?.(e));
    window.addEventListener('mousemove', (e) => this.updateMousePosition?.(e));
    window.addEventListener('mouseup', () => this.mouseUpCallback?.());
  }

  // Mouse event callbacks
  setMouseDownCallback(callback: (e: MouseEvent) => void) {
    this.mouseDownCallback = callback;
  }

  setMouseMoveCallback(callback: (e: MouseEvent) => void) {
    this.mouseMoveCallback = callback;
  }

  setMouseUpCallback(callback: () => void) {
    this.mouseUpCallback = callback;
  }

  updateMousePosition(e: MouseEvent) {

    const rawMouseX = e.clientX;
    const rawMouseY = e.clientY;

    // TODO: make scene scale global
    const sceneScale = 176;
    this.mousePosition.x = ((2 * rawMouseX / window.innerWidth) - 1) * (window.innerWidth / window.innerHeight) * (sceneScale / 2);
    this.mousePosition.y = - ((2 * rawMouseY / window.innerHeight) - 1) * (sceneScale / 2);
    this.mouseMoveCallback?.(e)
  }

  getMousePosition(): Vec2 {
    return this.mousePosition;
  }

  isKeyDown(key: string): boolean {
    return this.keys.has(key.toLowerCase());
  }

  clear(): void {
    this.keys.clear();
    this.mouseButtons.clear();
  }
}