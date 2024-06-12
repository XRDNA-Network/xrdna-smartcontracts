
import { ERC20AssetFactory, ERC20AssetRegistry } from "../../../../src";
import { IBasicDeployArgs, IDeployable } from "../../IDeployable";
import { IERC20AssetStack } from "./IERC20AssetStack";
import { StackFactory} from '../../StackFactory';
import { IWorldStackDeployment } from "../../world/WorldStackImpl";


export interface IAssetStackArgs extends IBasicDeployArgs {

}

export class ERC20AssetStackImpl implements IERC20AssetStack, IDeployable {

    constructor(readonly factory: StackFactory, readonly world: IWorldStackDeployment) {
        
    }

    getEC20Factory(): ERC20AssetFactory {
        return this.world.erc20AssetFactory;
    }

    getERC20Registry(): ERC20AssetRegistry {
        return this.world.erc20AssetRegistry;
    }
    
    async deploy(): Promise<void> { }

}