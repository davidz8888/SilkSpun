import { Vec2 } from "../math/Vec2";

export class InputController {
  private static keys: Set<string> = new Set<string>();
  private static mouseButtons: Set<number>;
  private static mousePosition: Vec2;
  private static mouseDownCallback: ((e: MouseEvent) => void) | null = null;
  private static mouseMoveCallback: ((e: MouseEvent) => void) | null = null;
  private static mouseUpCallback: (() => void) | null = null;

  static {
    InputController.keys;
    InputController.mouseButtons = new Set<number>();
    InputController.mousePosition = new Vec2(0, 0);

    window.addEventListener('keydown', (e) => InputController.keys.add(e.key.toLowerCase()));
    window.addEventListener('keyup', (e) => InputController.keys.delete(e.key.toLowerCase()));
    window.addEventListener('mousedown', (e) => InputController.mouseDownCallback?.(e));
    window.addEventListener('mousemove', (e) => InputController.updateMousePosition?.(e));
    window.addEventListener('mouseup', () => InputController.mouseUpCallback?.());
  }

  // Mouse event callbacks
  static setMouseDownCallback(callback: (e: MouseEvent) => void) {
    InputController.mouseDownCallback = callback;
  }

  static setMouseMoveCallback(callback: (e: MouseEvent) => void) {
    InputController.mouseMoveCallback = callback;
  }

  static setMouseUpCallback(callback: () => void) {
    InputController.mouseUpCallback = callback;
  }

  static updateMousePosition(e: MouseEvent) {

    const rawMouseX = e.clientX;
    const rawMouseY = e.clientY;

    // TODO: make scene scale global
    const sceneScale = 176;
    InputController.mousePosition.x = ((2 * rawMouseX / window.innerWidth) - 1) * (window.innerWidth / window.innerHeight) * (sceneScale / 2);
    InputController.mousePosition.y = - ((2 * rawMouseY / window.innerHeight) - 1) * (sceneScale / 2);
    InputController.mouseMoveCallback?.(e)
  }

  static getMousePosition(): Vec2 {
    return InputController.mousePosition;
  }

  static isKeyDown(key: string): boolean {
    return InputController.keys.has(key.toLowerCase());
  }

  static clear(): void {
    InputController.keys.clear();
    InputController.mouseButtons.clear();
  }
}