
import { ERC721AssetFactory, ERC721AssetRegistry } from "../../../../src";
import { IBasicDeployArgs, IDeployable } from "../../IDeployable";
import { IERC721AssetStack } from "./IERC721AssetStack";
import { StackFactory} from '../../StackFactory';
import { IWorldStackDeployment } from "../../world/WorldStackImpl";


export interface IAssetStackArgs extends IBasicDeployArgs {

}

export class ERC721AssetStackImpl implements IERC721AssetStack, IDeployable {

    constructor(readonly factory: StackFactory, readonly world: IWorldStackDeployment) {
        
    }

    getEC721Factory(): ERC721AssetFactory {
        return this.world.erc721AssetFactory;
    }

    getERC721Registry(): ERC721AssetRegistry {
        return this.world.erc721AssetRegistry;
    }
    
    async deploy(): Promise<void> { }

}