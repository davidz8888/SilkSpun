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
    radius: 0.0
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


export const sunLight: InfiniteLight = {
    direction: new THREE.Vector3(0.0, 1.0, 1.0),
    color: new THREE.Vector3(1.0, 1.0, 0.7),
    shadowDistance: 30.0
}

export const moonLight: InfiniteLight = {
    direction: new THREE.Vector3(0.0, 0.0, .0),
    color: new THREE.Vector3(1.0, 1.0, 0.7),
    shadowDistance: 30.0
}


export const infiniteLights: InfiniteLight[] = [];
infiniteLights.push(sunLight);
infiniteLights.push(moonLight);


export function updateDayNight(): void {
    const millisInDay = 60 * 1000; // 1 minute = full day cycle
    const currentTime = (Date.now() % millisInDay) / millisInDay; // 0 to 1 range
    const timeOfDay = currentTime * 24; // Convert 0-1 to 0-24 hour cycle

    updateSky(timeOfDay);
    updateSun(timeOfDay);

}


function updateSky(timeOfDay: number): void{
    const morningColor = new THREE.Vector3(0.3, 0.2, 0.1);  // Orange (Sunrise)
    const noonColor = new THREE.Vector3(0.1, 0.3, 0.5);     // White (Noon)
    const eveningColor = new THREE.Vector3(0.3, 0.2, 0.1);  // Red/Purple (Sunset)
    const nightColor = new THREE.Vector3(0.0, 0.0, 0.015);   // Dark Blue (Night)

    // Interpolate colors based on the time of day (morning → noon → evening → night)
    if (timeOfDay < 4) {
        skyLight.color = nightColor;
    } else if (timeOfDay < 7) {
        skyLight.color.lerpVectors(nightColor, morningColor, (timeOfDay - 4)/3);
    } else if (timeOfDay < 9) {
        skyLight.color.lerpVectors(morningColor, noonColor, (timeOfDay - 7)/2);
    } else if (timeOfDay < 15) {
        skyLight.color = noonColor;
    } else if (timeOfDay < 17){
        skyLight.color.lerpVectors(noonColor, eveningColor, (timeOfDay - 15)/2);
    } else if (timeOfDay < 20){
        skyLight.color.lerpVectors(eveningColor, nightColor, (timeOfDay - 17)/3);
    } else {
        skyLight.color = nightColor;
    }
}


function updateSun(timeOfDay: number): void{


    const morningColor = new THREE.Vector3(1.0, 0.0, 0.0);
    const noonColor = new THREE.Vector3(1.0, 0.9, 0.8);
    const eveningColor = new THREE.Vector3(1.0, 0.0, 0.0);
    const nightColor = new THREE.Vector3(0.0, 0.0, 0.0);

    const morningDirection = new THREE.Vector3(1.0, 0.0, 0.0);
    const noonDirection = new THREE.Vector3(0.0, 1.0, 1.0);
    const eveningDirection = new THREE.Vector3(-1.0, 0.0, 0.0);


    if (timeOfDay < 5) {
        sunLight.color = nightColor;
    } else if (timeOfDay < 7) {
        sunLight.color.lerpVectors(nightColor, morningColor, (timeOfDay - 5)/2);
    } else if (timeOfDay < 8) {
        sunLight.color.lerpVectors(morningColor, noonColor, (timeOfDay - 7)/1);
    } else if (timeOfDay < 16) {
        sunLight.color = noonColor;
    } else if (timeOfDay < 17){
        sunLight.color.lerpVectors(noonColor, eveningColor, (timeOfDay - 16)/1);
    } else if (timeOfDay < 19){
        sunLight.color.lerpVectors(eveningColor, nightColor, (timeOfDay - 17)/2);
    } else {
        sunLight.color = nightColor;
    }


    if (timeOfDay < 6) {
        sunLight.direction = morningDirection;
    } else if (timeOfDay < 12) {
        sunLight.direction.lerpVectors(morningDirection, noonDirection, (timeOfDay - 6)/6);
    } else if (timeOfDay < 18) {
        sunLight.direction.lerpVectors(noonDirection, eveningDirection, (timeOfDay - 12)/6);
    } else {
        sunLight.direction = eveningDirection;
    }

}