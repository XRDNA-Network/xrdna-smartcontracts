import { AssetFactory, AssetRegistry } from "../../../src";
import { IBasicDeployArgs, IDeployable } from "../IDeployable";
import { IAssetStack } from "./IAssetStack";
import { StackFactory} from '../StackFactory';
import { IWorldStackDeployment } from "../world/WorldStackImpl";


export interface IAssetStackArgs extends IBasicDeployArgs {

}

export class AssetStackImpl implements IAssetStack, IDeployable {

    constructor(readonly factory: StackFactory, readonly world: IWorldStackDeployment) {
        
    }

    getAssetFactory(): AssetFactory {
       return this.world.assetFactory;
    }

    getAssetRegistry(): AssetRegistry {
        return this.world.assetRegistry;
    }

    
    async deploy(): Promise<void> { }

}