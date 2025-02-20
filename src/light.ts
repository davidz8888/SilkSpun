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

export const pointLights: PointLight[] = [];

pointLights.push({
    positionWorld: new THREE.Vector3(50.0, 50.0, 15.0),
    color: new THREE.Vector3(1.0, 1.0, 1.0),
    falloff: 0.2,
    radius: 300.0
});
pointLights.push({
    positionWorld: new THREE.Vector3(-50.0, -50.0, 15.0),
    color: new THREE.Vector3(0.0, 1.0, 1.0),
    falloff: 0.2,
    radius: 0.0
});
pointLights.push({
    positionWorld: new THREE.Vector3(-50.0, 50.0, 15.0),
    color: new THREE.Vector3(1.0, 1.0, 0.0),
    falloff: 0.2,
    radius: 0.0
});
pointLights.push({
    positionWorld: new THREE.Vector3(50.0, -50.0, 15.0),
    color: new THREE.Vector3(0.0, 0.0, 1.0),
    falloff: 0.2,
    radius: 0.0
});

export const skyLight: SkyLight = {
    color: new THREE.Vector3(0.05, 0.15, 0.2),
    shadowDistance: 20.0
};

export const infiniteLight: InfiniteLight = {
    direction: new THREE.Vector3(0.0, 1.0, 1.0),
    color: new THREE.Vector3(1.0, 1.0, 0.7),
    shadowDistance: 30.0
}


export function updateSkyLight(): void {
    // Convert time (0-24) into an angle for sun movement (radians)
    const millisInDay = 60 * 1000; // 1 minute = full day cycle
    const currentTime = (Date.now() % millisInDay) / millisInDay; // 0 to 1 range
    const timeOfDay = currentTime * 24; // Convert 0-1 to 0-24 hour cycle
    // Set light direction: rotates from east (-x) to west (+x)

    const morningColor = new THREE.Vector3(1.0, 0.5, 0.2);  // Orange (Sunrise)
    const noonColor = new THREE.Vector3(0.8, 1.0, 1.0);     // White (Noon)
    const eveningColor = new THREE.Vector3(1.0, 0.3, 0.3);  // Red/Purple (Sunset)
    const nightColor = new THREE.Vector3(0.02, 0.05, 0.1);   // Dark Blue (Night)

    // Interpolate colors based on the time of day (morning → noon → evening → night)
    if (timeOfDay < 5) {
        skyLight.color = nightColor;
    } else if (timeOfDay < 7) {
        skyLight.color.lerpVectors(nightColor, morningColor, (timeOfDay - 5)/2);
    } else if (timeOfDay < 9) {
        skyLight.color.lerpVectors(morningColor, noonColor, (timeOfDay - 7)/2);
    } else if (timeOfDay < 15) {
        skyLight.color = noonColor;
    } else if (timeOfDay < 17){
        skyLight.color.lerpVectors(noonColor, eveningColor, (timeOfDay - 15)/2);
    } else if (timeOfDay < 19){
        skyLight.color.lerpVectors(eveningColor, nightColor, (timeOfDay - 17)/2);
    } else {
        skyLight.color = nightColor;
    }
}