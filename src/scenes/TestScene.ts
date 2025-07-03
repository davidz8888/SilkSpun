import { PassiveEntity } from '../entities/PassiveEntity';
import { MoveableLight } from '../entities/MoveableLight'
import { Scene } from '../core/Scene';
import { Layer } from '../core/Layer';
import { BackgroundEntity } from '../entities/BackgroundEntity';
import { Candle } from '../entities/Candle';


export class TestScene extends Scene {

    constructor() {

        super()

        const moveableLight = new MoveableLight('moveable_light');
        const lightLayer = new Layer('light_layer', -165);
        lightLayer.addEntity(moveableLight, -40, -20);

        this.addLayer(lightLayer);

        // const fluids = new PassiveEntity('test_fluid');
        // const fluidLayer = new Layer('fluid_layer', -10);
        // fluidLayer.addEntity(fluids, 0, 0);

        // this.addLayer(fluidLayer);


        const lotus = new PassiveEntity('lotus', 5.0);
        const lotusLayer = new Layer('lotus_layer', -180);
        lotusLayer.addEntity(lotus, -40, -34);

        this.addLayer(lotusLayer);

        const buddha = new PassiveEntity('buddha', 5.0);
        const buddhaLayer = new Layer('buddha_layer', -185);
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
        const floorLayer = new Layer('floor_layer', -55);
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


        const candleLayerBack = new Layer('candle_layer_back', -61);

        const candleA = new Candle();
        candleLayerBack.addEntity(candleA, 0, -70);

        const candleB = new Candle();
        candleLayerBack.addEntity(candleB, 5, -74);

        const candleC = new Candle();
        candleLayerBack.addEntity(candleC, -6, -75);

        const candleD = new Candle();
        candleLayerBack.addEntity(candleD, -80, -70);

        const candleE = new Candle();
        candleLayerBack.addEntity(candleE, -75, -74);

        const candleF = new Candle();
        candleLayerBack.addEntity(candleF, -86, -75);


        this.addLayer(candleLayerBack);
    }

}