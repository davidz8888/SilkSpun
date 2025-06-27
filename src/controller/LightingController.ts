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


export class LightingController {

    private static pointLights: PointLight[] = [];
    private static infiniteLights: InfiniteLight[] = [];
    private static skyLight: SkyLight = {
        color: new Vec3(0.2, 0.2, 0.4),
        shadowDistance: 10.0
    };;

    private static sunLight: InfiniteLight = {
        direction: new Vec3(0.5, 0.5, 0.4),
        color: new Vec3(1.0, 1.0, 0.8),
        shadowDistance: 30.0
    }

    static {
        LightingController.infiniteLights.push(LightingController.sunLight);    
    }

    static addPointLight(pointLight: PointLight) {
        LightingController.pointLights.push(pointLight);
    }


    static updateDayNight(): void {
        const millisInDay = 60 * 1000; // 1 minute = full day cycle
        const currentTime = (Date.now() % millisInDay) / millisInDay; // 0 to 1 range
        const timeOfDay = currentTime * 24; // Convert 0-1 to 0-24 hour cycle

        LightingController.updateSky(timeOfDay);
        LightingController.updateSun(timeOfDay);

    }

    static debugDayNight(): void {
        const millisInDay = 60 * 1000; // 1 minute = full day cycle
        const currentTime = (Date.now() % millisInDay) / millisInDay; // 0 to 1 range
        const timeOfDay = currentTime * 24; // Convert 0-1 to 0-24 hour cycle

        LightingController.skyLight.color = Vec3.lerp(new Vec3(0), new Vec3(1), timeOfDay / 24);
        LightingController.sunLight.color = new Vec3(0);

    }

    static updateSky(timeOfDay: number): void {
        const morningColor = new Vec3(0.3, 0.2, 0.1);  // Orange (Sunrise)
        const noonColor = new Vec3(0.1, 0.3, 0.5);     // White (Noon)
        const eveningColor = new Vec3(0.3, 0.2, 0.1);  // Red/Purple (Sunset)
        const nightColor = new Vec3(0.0, 0.0, 0.015);   // Dark Blue (Night)

        // Interpolate colors based on the time of day (morning → noon → evening → night)
        if (timeOfDay < 4) {
            LightingController.skyLight.color = nightColor;
        } else if (timeOfDay < 7) {
            LightingController.skyLight.color = Vec3.lerp(nightColor, morningColor, (timeOfDay - 4) / 3);
        } else if (timeOfDay < 9) {
            LightingController.skyLight.color = Vec3.lerp(morningColor, noonColor, (timeOfDay - 7) / 2);
        } else if (timeOfDay < 15) {
            LightingController.skyLight.color = noonColor;
        } else if (timeOfDay < 17) {
            LightingController.skyLight.color = Vec3.lerp(noonColor, eveningColor, (timeOfDay - 15) / 2);
        } else if (timeOfDay < 20) {
            LightingController.skyLight.color = Vec3.lerp(eveningColor, nightColor, (timeOfDay - 17) / 3);
        } else {
            LightingController.skyLight.color = nightColor;
        }

    }


    static updateSun(timeOfDay: number): void {

        const morningColor = new Vec3(1.0, 0.0, 0.0);
        const noonColor = new Vec3(1.0, 0.9, 0.8);
        const eveningColor = new Vec3(1.0, 0.0, 0.0);
        const nightColor = new Vec3(0.0, 0.0, 0.0);

        const morningDirection = new Vec3(1.0, 0.0, 0.0);
        const noonDirection = new Vec3(0.0, 1.0, 1.0);
        const eveningDirection = new Vec3(-1.0, 0.0, 0.0);


        if (timeOfDay < 5) {
            LightingController.sunLight.color = nightColor;
        } else if (timeOfDay < 7) {
            LightingController.sunLight.color = Vec3.lerp(nightColor, morningColor, (timeOfDay - 5) / 2);
        } else if (timeOfDay < 8) {
            LightingController.sunLight.color = Vec3.lerp(morningColor, noonColor, (timeOfDay - 7) / 1);
        } else if (timeOfDay < 16) {
            LightingController.sunLight.color = noonColor;
        } else if (timeOfDay < 17) {
            LightingController.sunLight.color = Vec3.lerp(noonColor, eveningColor, (timeOfDay - 16) / 1);
        } else if (timeOfDay < 19) {
            LightingController.sunLight.color = Vec3.lerp(eveningColor, nightColor, (timeOfDay - 17) / 2);
        } else {
            LightingController.sunLight.color = nightColor;
        }


        if (timeOfDay < 6) {
            LightingController.sunLight.direction = morningDirection;
        } else if (timeOfDay < 12) {
            LightingController.sunLight.direction = Vec3.lerp(morningDirection, noonDirection, (timeOfDay - 6) / 6);
        } else if (timeOfDay < 18) {
            LightingController.sunLight.direction = Vec3.lerp(noonDirection, eveningDirection, (timeOfDay - 12) / 6);
        } else {
            LightingController.sunLight.direction = eveningDirection;
        }
    }

    static getPointLights(): PointLight[] {
        return LightingController.pointLights;
    }
    
    static getInfiniteLights(): InfiniteLight[] {
        return LightingController.infiniteLights;
    }

    static getSkyLight(): SkyLight {
        return LightingController.skyLight;
    }
    
}

