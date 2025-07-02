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
        lotusLayer.addEntity(lotus, -40, -34);

        this.addLayer(lotusLayer);

        const buddha = new PassiveEntity('buddha');
        const buddhaLayer = new Layer('buddha_layer', -25);
        buddhaLayer.addEntity(buddha, -40, -4);

        this.addLayer(buddhaLayer);



        const wall = new PassiveEntity('temple_wall', 64);
        const wallLayer = new Layer('wall_layer', -45);
        wallLayer.addEntity(wall, 0, 0);

        this.addLayer(wallLayer);

        
        const testBackgroud = new PassiveEntity('test_background');
        const backgroundLayer = new Layer('backgroundLayer', -100);
        backgroundLayer.addEntity(testBackgroud, 0, 0);

        this.addLayer(backgroundLayer);
    }

}