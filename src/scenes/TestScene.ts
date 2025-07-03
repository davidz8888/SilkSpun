import { PassiveEntity } from '../entities/PassiveEntity';
import { MoveableLight } from '../entities/MoveableLight'
import { Scene } from '../core/Scene';
import { Layer } from '../core/Layer';
import { BackgroundEntity } from '../entities/BackgroundEntity';
import { Candle } from '../entities/Candle';


export class TestScene extends Scene {

    constructor() {

        super()

        const moveableLight = new MoveableLight('candle');
        const lightLayer = new Layer('light_layer', -61);
        lightLayer.addEntity(moveableLight, 0, 0);

        this.addLayer(lightLayer);

        // const fluids = new PassiveEntity('test_fluid');
        // const fluidLayer = new Layer('fluid_layer', -10);
        // fluidLayer.addEntity(fluids, 0, 0);

        // this.addLayer(fluidLayer);


        const lotus = new PassiveEntity('lotus', 5.0);
        const lotusLayer = new Layer('lotus_layer', -190);
        lotusLayer.addEntity(lotus, -40, -34);

        this.addLayer(lotusLayer);

        const buddha = new PassiveEntity('buddha', 5.0);
        const buddhaLayer = new Layer('buddha_layer', -195);
        buddhaLayer.addEntity(buddha, -40, -4);

        this.addLayer(buddhaLayer);

        const stairs = new PassiveEntity('temple_stairs', 100);
        const stairsLayer = new Layer('wall_layer', -160);
        stairsLayer.addEntity(stairs, -40, -64);

        this.addLayer(stairsLayer);

        const wall = new PassiveEntity('temple_wall', 32);
        const wallLayer = new Layer('wall_layer', -200);
        wallLayer.addEntity(wall, 0, 0);

        this.addLayer(wallLayer);

        const floor = new PassiveEntity('temple_floor');
        const floorLayer = new Layer('floor_layer', -60);
        floorLayer.addEntity(floor, 0, -80);
        this.addLayer(floorLayer);

        const struts = new PassiveEntity('temple_struts');
        const strutLayer = new Layer('strut_layer', -55);
        strutLayer.addEntity(struts, -40, 64);
        this.addLayer(strutLayer);


        const testBackgroud = new PassiveEntity('test_background');
        const backgroundLayer = new Layer('backgroundLayer', -1000);
        backgroundLayer.addEntity(testBackgroud, 0, 0);

        this.addLayer(backgroundLayer);

        const candleA = new Candle();
        const candleLayer = new Layer('candle_layer', -61);
        candleLayer.addEntity(candleA, 0, -100);

        this.addLayer(candleLayer);
    }

}