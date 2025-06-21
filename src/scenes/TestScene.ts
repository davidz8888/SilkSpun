// src/scenes/TestScene.ts

import { PassiveEntity } from '../entities/PassiveEntity';
import { MoveableLight } from '../entities/MoveableLight'
import { Scene } from '../core/Scene';
import { Layer } from '../core/Layer';
import { InputController } from '../controller/InputController';


export class TestScene extends Scene {

    constructor() {
        super()

        const inputController: InputController = new InputController();

        const moveableLight = new MoveableLight('transparent');
        moveableLight.setInputController(inputController);
        const lightLayer = new Layer('light_layer', -20);
        lightLayer.addEntity(moveableLight, 0, 0);

        this.addLayer(lightLayer);

        const testFloor = new PassiveEntity('test_materials');
        const floorLayer = new Layer('floor_layer', -60);
        floorLayer.addEntity(testFloor, 0, 0);

        this.addLayer(floorLayer);

        // this.testWall = new PassiveEntity('test_wall');
        // this.wallLayer = new Layer('wall_layer', -50);
        // this.wallLayer.addEntity(this.testWall, 0, 0);

        // this.addLayer(this.wallLayer);
    }

}