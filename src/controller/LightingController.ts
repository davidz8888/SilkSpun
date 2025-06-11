// src/controllers/LightController.ts

import * as THREE from 'three';

/**
 * LightController class
 * Handles keyboard controls to move a light around the scene.
 */
export class LightController {
  public position: THREE.Vector3;
  private moveSpeed: number;
  private keyState: Record<string, boolean> = {};
  private sprite: THREE.Sprite;
  private initialPosition: THREE.Vector3;

  constructor(sprite: THREE.Sprite, initialPosition: THREE.Vector3 = new THREE.Vector3(0, 0, 0), moveSpeed: number = 50.0) {
    this.sprite = sprite;
    this.moveSpeed = moveSpeed;
    this.position = initialPosition.clone();
    this.initialPosition = initialPosition.clone();

    // Set up event listeners
    window.addEventListener('keydown', (e) => this.onKeyDown(e));
    window.addEventListener('keyup', (e) => this.onKeyUp(e));
  }

  private onKeyDown(e: KeyboardEvent) {
    this.keyState[e.key.toLowerCase()] = true;
  }

  private onKeyUp(e: KeyboardEvent) {
    this.keyState[e.key.toLowerCase()] = false;
  }

  /**
   * Update the light's position based on key input.
   */
  public update(deltaTime: number) {
    if (this.keyState['w']) this.position.y += this.moveSpeed * deltaTime;
    if (this.keyState['s']) this.position.y -= this.moveSpeed * deltaTime;
    if (this.keyState['a']) this.position.x -= this.moveSpeed * deltaTime;
    if (this.keyState['d']) this.position.x += this.moveSpeed * deltaTime;
    if (this.keyState['e']) this.position.z += this.moveSpeed * deltaTime;
    if (this.keyState['q']) this.position.z -= this.moveSpeed * deltaTime;
    if (this.keyState['r']) this.resetPosition();

    // Update the sprite's position to match
    this.sprite.position.copy(this.position);
  }

  /**
   * Reset position to initial value.
   */
  private resetPosition() {
    this.position.copy(this.initialPosition);
  }

  /**
   * Dispose of event listeners when no longer needed.
   */
  public dispose() {
    window.removeEventListener('keydown', (e) => this.onKeyDown(e));
    window.removeEventListener('keyup', (e) => this.onKeyUp(e));
  }
}