import { StackFactory } from "../StackFactory";
import { IWorldStackDeployment } from "../world/WorldStackImpl";
import { IMultiAssetRegistryStack } from "./IMultiAssetRegistryStack";

export class MultiAssetRegistryStackImpl implements IMultiAssetRegistryStack {

        constructor(readonly factory: StackFactory, readonly world: IWorldStackDeployment) {  }

        getMultiAssetRegistry() {
            return this.world.multiAssetRegistry;
        }
}