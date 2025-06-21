import { Vec3 } from '../math/Vec3';

export interface PointLight {
    positionWorld: Vec3;
    color: Vec3;
    falloff: number;
    radius: number;
}

export interface SkyLight {
    color: Vec3;
    shadowDistance: number;
}

export interface InfiniteLight {
    direction: Vec3;
    color: Vec3;
    shadowDistance: number;
}

export const pointLights: PointLight[] = [];

export function addPointLight(pointLight: PointLight) {
    pointLights.push(pointLight);
}

// pointLights.push({
//     positionWorld: new Vec3(0.0, 0.0, -1.0),
//     color: new Vec3(1.0, 1.0, 1.0),
//     falloff: 0.0,
//     radius: 50
// });


export const skyLight: SkyLight = {
    color: new Vec3(0.7, 0.7, 1.0),
    shadowDistance: 10.0
};


export const sunLight: InfiniteLight = {
    direction: new Vec3(0.0, 0.0, 0.0),
    color: new Vec3(0.0, 0.0, 0.0),
    shadowDistance: 30.0
}

export const moonLight: InfiniteLight = {
    direction: new Vec3(0.0, 0.0, 0.0),
    color: new Vec3(0.0, 0.0, 0.0),
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

export function debugDayNight(): void {
    const millisInDay = 60 * 1000; // 1 minute = full day cycle
    const currentTime = (Date.now() % millisInDay) / millisInDay; // 0 to 1 range
    const timeOfDay = currentTime * 24; // Convert 0-1 to 0-24 hour cycle

    skyLight.color = Vec3.lerp(new Vec3(0), new Vec3(1), timeOfDay/24);
    sunLight.color = new Vec3(0);

}

function updateSky(timeOfDay: number): void{
    const morningColor = new Vec3(0.3, 0.2, 0.1);  // Orange (Sunrise)
    const noonColor = new Vec3(0.1, 0.3, 0.5);     // White (Noon)
    const eveningColor = new Vec3(0.3, 0.2, 0.1);  // Red/Purple (Sunset)
    const nightColor = new Vec3(0.0, 0.0, 0.015);   // Dark Blue (Night)

    // Interpolate colors based on the time of day (morning → noon → evening → night)
    if (timeOfDay < 4) {
        skyLight.color = nightColor;
    } else if (timeOfDay < 7) {
        skyLight.color = Vec3.lerp(nightColor, morningColor, (timeOfDay - 4)/3);
    } else if (timeOfDay < 9) {
        skyLight.color = Vec3.lerp(morningColor, noonColor, (timeOfDay - 7)/2);
    } else if (timeOfDay < 15) {
        skyLight.color = noonColor;
    } else if (timeOfDay < 17){
        skyLight.color = Vec3.lerp(noonColor, eveningColor, (timeOfDay - 15)/2);
    } else if (timeOfDay < 20){
        skyLight.color = Vec3.lerp(eveningColor, nightColor, (timeOfDay - 17)/3);
    } else {
        skyLight.color = nightColor;
    }

}


function updateSun(timeOfDay: number): void{

    const morningColor = new Vec3(1.0, 0.0, 0.0);
    const noonColor = new Vec3(1.0, 0.9, 0.8);
    const eveningColor = new Vec3(1.0, 0.0, 0.0);
    const nightColor = new Vec3(0.0, 0.0, 0.0);

    const morningDirection = new Vec3(1.0, 0.0, 0.0);
    const noonDirection = new Vec3(0.0, 1.0, 1.0);
    const eveningDirection = new Vec3(-1.0, 0.0, 0.0);


    if (timeOfDay < 5) {
        sunLight.color = nightColor;
    } else if (timeOfDay < 7) {
        sunLight.color = Vec3.lerp(nightColor, morningColor, (timeOfDay - 5)/2);
    } else if (timeOfDay < 8) {
        sunLight.color = Vec3.lerp(morningColor, noonColor, (timeOfDay - 7)/1);
    } else if (timeOfDay < 16) {
        sunLight.color = noonColor;
    } else if (timeOfDay < 17){
        sunLight.color = Vec3.lerp(noonColor, eveningColor, (timeOfDay - 16)/1);
    } else if (timeOfDay < 19){
        sunLight.color = Vec3.lerp(eveningColor, nightColor, (timeOfDay - 17)/2);
    } else {
        sunLight.color = nightColor;
    }


    if (timeOfDay < 6) {
        sunLight.direction = morningDirection;
    } else if (timeOfDay < 12) {
        sunLight.direction = Vec3.lerp(morningDirection, noonDirection, (timeOfDay - 6)/6);
    } else if (timeOfDay < 18) {
        sunLight.direction = Vec3.lerp(noonDirection, eveningDirection, (timeOfDay - 12)/6);
    } else {
        sunLight.direction = eveningDirection;
    }

}