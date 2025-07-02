import { Vec2 } from "../math/Vec2";

export class InputController {
  private static keys: Set<string> = new Set<string>();
  private static mouseButtons: Set<number>;
  private static mousePosition: Vec2;

  private static keyDownCallbacks: Array<(e: KeyboardEvent) => void> = [];
  private static keyUpCallbacks: Array<(e: KeyboardEvent) => void> = [];

  private static mouseDownCallbacks: Array<(e: MouseEvent) => void> = [];
  private static mouseMoveCallbacks: Array<(e: MouseEvent) => void> = [];
  private static mouseUpCallbacks: Array<() => void> = [];

  static {
    InputController.keys;
    InputController.mouseButtons = new Set<number>();
    InputController.mousePosition = new Vec2(0, 0);

    window.addEventListener('keydown', (e) => {
      const key = e.key.toLowerCase();
      InputController.keys.add(key);
      for (const cb of InputController.keyDownCallbacks) cb(e);
    });

    window.addEventListener('keyup', (e) => {
      const key = e.key.toLowerCase();
      InputController.keys.delete(key);
      for (const cb of InputController.keyUpCallbacks) cb(e);
    });

    window.addEventListener('mousedown', (e) => {
      for (const cb of InputController.mouseDownCallbacks) cb(e);
    });

    window.addEventListener('mousemove', (e) => {
      InputController.updateMousePosition(e);
    });

    window.addEventListener('mouseup', () => {
      for (const cb of InputController.mouseUpCallbacks) cb();
    });
  }

  static addKeyDownCallback(callback: (e: KeyboardEvent) => void) {
    InputController.keyDownCallbacks.push(callback);
  }

  static removeKeyDownCallback(callback: (e: KeyboardEvent) => void) {
    InputController.keyDownCallbacks = InputController.keyDownCallbacks.filter(cb => cb !== callback);
  }

  static addKeyUpCallback(callback: (e: KeyboardEvent) => void) {
    InputController.keyUpCallbacks.push(callback);
  }

  static removeKeyUpCallback(callback: (e: KeyboardEvent) => void) {
    InputController.keyUpCallbacks = InputController.keyUpCallbacks.filter(cb => cb !== callback);
  }

  static addMouseDownCallback(callback: (e: MouseEvent) => void) {
    InputController.mouseDownCallbacks.push(callback);
  }

  static removeMouseDownCallback(callback: (e: MouseEvent) => void) {
    InputController.mouseDownCallbacks = InputController.mouseDownCallbacks.filter(cb => cb !== callback);
  }

  static addMouseMoveCallback(callback: (e: MouseEvent) => void) {
    InputController.mouseMoveCallbacks.push(callback);
  }

  static removeMouseMoveCallback(callback: (e: MouseEvent) => void) {
    InputController.mouseMoveCallbacks = InputController.mouseMoveCallbacks.filter(cb => cb !== callback);
  }

  static addMouseUpCallback(callback: () => void) {
    InputController.mouseUpCallbacks.push(callback);
  }

  static removeMouseUpCallback(callback: () => void) {
    InputController.mouseUpCallbacks = InputController.mouseUpCallbacks.filter(cb => cb !== callback);
  }

  static updateMousePosition(e: MouseEvent) {
    const rawMouseX = e.clientX;
    const rawMouseY = e.clientY;

    const sceneScale = 176; // TODO: make scene scale global
    InputController.mousePosition.x = ((2 * rawMouseX / window.innerWidth) - 1) * (window.innerWidth / window.innerHeight) * (sceneScale / 2);
    InputController.mousePosition.y = -((2 * rawMouseY / window.innerHeight) - 1) * (sceneScale / 2);

    for (const cb of InputController.mouseMoveCallbacks) cb(e);
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
