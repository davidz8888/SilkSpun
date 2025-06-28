import { PassiveEntity } from '../entities/PassiveEntity';
import { MoveableLight } from '../entities/MoveableLight'
import { Scene } from '../core/Scene';
import { Layer } from '../core/Layer';


export class TestScene extends Scene {

    constructor() {
        super()


        const moveableLight = new MoveableLight('transparent');
        const lightLayer = new Layer('light_layer', 0);
        lightLayer.addEntity(moveableLight, 0, 0);

        this.addLayer(lightLayer);

        // const fluids = new PassiveEntity('test_fluid');
        // const fluidLayer = new Layer('fluid_layer', -10);
        // fluidLayer.addEntity(fluids, 0, 0);

        // this.addLayer(fluidLayer);

        const lotus = new PassiveEntity('lotus');
        const lotusLayer = new Layer('lotus_layer', -20);
        lotusLayer.addEntity(lotus, -50, -30);

        this.addLayer(lotusLayer);

        const buddha = new PassiveEntity('buddha');
        const buddhaLayer = new Layer('buddha_layer', -25);
        buddhaLayer.addEntity(buddha, -50, 0);

        this.addLayer(buddhaLayer);


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