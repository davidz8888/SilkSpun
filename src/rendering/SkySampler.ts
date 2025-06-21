// src/rendering/SphereSampler.ts

import * as THREE from 'three';

export class SkySampler {

    
    public static generateSkySamples(numSamples: number): THREE.Vector3[] {

        const sampleSet: THREE.Vector3[] = [];

        for (let i = 0; i < numSamples; i++) {

            const theta = Math.random() * Math.PI;  // Random azimuthal angle
            const phi = Math.acos(Math.random());  // Random polar angle

            const x = Math.sin(phi) * Math.cos(theta);
            const y = Math.sin(phi) * Math.sin(theta);
            const z = Math.cos(phi);

            const sample = new THREE.Vector3(x, y, z);

            console.log(sample);

            sampleSet.push(sample);

        }

        return sampleSet;
    }

    public static generateSamples(numSamples: number, x_min = -1.0, x_max = 1.0, y_min = -1.0, y_max = 1.0, z_min = -1.0, z_max = 1.0) {

        const sampleSet: THREE.Vector3[] = [];

        while (sampleSet.length < numSamples) {
            
            const sample: THREE.Vector3 = this.singleUnitSphereSample();
            if (sample.x < x_min || 
                sample.x > x_max ||
                sample.y < y_min ||
                sample.y > y_max ||
                sample.z < z_min ||
                sample.z > z_max) continue;
            
            sampleSet.push(sample)

        }

        return sampleSet;
    }
    
    private static singleUnitSphereSample(): THREE.Vector3 {

        const theta = Math.random() * 2 * Math.PI;  // Random azimuthal angle
        const phi = Math.acos(2 * Math.random() - 1);  // Random polar angle

        const x = Math.sin(phi) * Math.cos(theta);
        const y = Math.sin(phi) * Math.sin(theta);
        const z = Math.cos(phi);

        return new THREE.Vector3(x, y, z);
    }
}

