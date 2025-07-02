// src/core/PassiveEntity.ts

import { ForegroundEntity } from './ForegroundEntity';

export class PassiveEntity extends ForegroundEntity {
    
    constructor(textureName: string | null = null, heightScaling = 10.0) {

        super(textureName, heightScaling);
    }

}