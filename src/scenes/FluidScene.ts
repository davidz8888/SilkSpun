import { PassiveEntity } from '../entities/PassiveEntity';
import { Scene } from '../core/Scene';
import { Layer } from '../core/Layer';


export class FluidScene extends Scene {

    constructor() {

        super()

        const fluids = new PassiveEntity('test_fluid');
        const fluidLayer = new Layer('fluid_layer', -10);
        fluidLayer.addEntity(fluids, 0, 0);

        this.addLayer(fluidLayer);
    }
}