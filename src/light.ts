import * as THREE from 'three';

export interface PointLight {
    positionWorld: THREE.Vector3;
    color: THREE.Vector3;
    falloff: number;
    radius: number;
}

export interface SkyLight {
    color: THREE.Vector3;
    shadowDistance: number;
}

export interface InfiniteLight {
    direction: THREE.Vector3;
    color: THREE.Vector3;
    shadowDistance: number;
}