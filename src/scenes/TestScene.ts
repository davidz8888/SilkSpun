// src/scenes/TestScene.ts

import { PassiveEntity } from '../entities/PassiveEntity';
import { MoveableLight } from '../entities/MoveableLight'
import { Scene } from '../core/Scene';
import { Layer } from '../core/Layer';


export class TestScene extends Scene {

    private floorLayer: Layer;
    private wallLayer: Layer;
    // private lightLayer: Layer;

    private testFloor: PassiveEntity;
    private testWall: PassiveEntity;
    // private moveableLight: MoveableLight;


    constructor() {
        super()

        // this.moveableLight = new MoveableLight('light');
        // this.lightLayer = new Layer('light_layer', -23);
        // this.lightLayer.addEntity(this.moveableLight, 0, 0);

        // this.addLayer


        this.testFloor = new PassiveEntity('test_floor');
        this.floorLayer = new Layer('floor_layer', -24);
        this.floorLayer.addEntity(this.testFloor, 0, 0);

        this.addLayer(this.floorLayer);

        this.testWall = new PassiveEntity('test_wall');
        this.wallLayer = new Layer('wall_layer', -302);
        this.wallLayer.addEntity(this.testWall, 0, 0);

        this.addLayer(this.wallLayer);
    }

}