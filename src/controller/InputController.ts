// src/controller/InputController.ts

export class InputController {
    private keys: Set<string>;
  
    constructor() {
      this.keys = new Set<string>();
  
      window.addEventListener('keydown', (e) => {
        this.keys.add(e.key.toLowerCase());
      });
  
      window.addEventListener('keyup', (e) => {
        this.keys.delete(e.key.toLowerCase());
      });
    }
  
    isKeyDown(key: string): boolean {
      return this.keys.has(key.toLowerCase());
    }
  
    clear(): void {
      this.keys.clear();
    }
  }
  