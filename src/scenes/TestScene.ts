// src/scenes/TestScene.ts

import { PassiveEntity } from '../core/PassiveEntity';
import { Scene } from '../core/Scene';
import { Layer } from '../core/Layer';


export class TestScene extends Scene {

    private floorLayer: Layer;
    private wallLayer: Layer;

    private testFloor: PassiveEntity;
    private testWall: PassiveEntity;


    constructor() {
        super()

        this.testFloor = new PassiveEntity('test_floor');
        this.testFloor.initMesh();

        this.floorLayer = new Layer('floor_layer', -24);
        this.floorLayer.addEntity(this.testFloor, 0, 0);

        this.addLayer(this.floorLayer);


        this.testWall = new PassiveEntity('test_wall');
        this.testWall.initMesh();

        this.wallLayer = new Layer('wall_layer', -302);
        this.wallLayer.addEntity(this.testWall, 0, 0);

        this.addLayer(this.wallLayer);
    }

}