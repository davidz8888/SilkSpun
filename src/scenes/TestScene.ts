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
        const lightLayer = new Layer('light_layer', 0);
        lightLayer.addEntity(moveableLight, 0, 0);

        this.addLayer(lightLayer);

        const goldBar = new PassiveEntity('lotus');
        const goldLayer = new Layer('gold_layer', -20);
        goldLayer.addEntity(goldBar, 0, -30);

        this.addLayer(goldLayer);

        const testFloor = new PassiveEntity('test_floor');
        const floorLayer = new Layer('floor_layer', -40);
        floorLayer.addEntity(testFloor, 0, 0);

        this.addLayer(floorLayer);

        const testWall = new PassiveEntity('test_wall');
        const wallLayer = new Layer('wall_layer', -50);
        wallLayer.addEntity(testWall, 0, 0);

        this.addLayer(wallLayer);
    }

}