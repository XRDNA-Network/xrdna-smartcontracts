import { AvatarFactory } from "../../../src/avatar/AvatarFactory";
import { AvatarRegistry } from "../../../src/avatar/AvatarRegistry";
import { IBasicDeployArgs, IDeployable } from "../IDeployable";
import { StackFactory, StackType } from "../StackFactory";
import { IAvatarStack } from "./IAvatarStack";
import { IWorldStackDeployment } from "../world/WorldStackImpl";


export interface IAvatarDeployArgs extends IBasicDeployArgs {}
export class AvatarStackImpl implements IAvatarStack, IDeployable {

    constructor(readonly factory: StackFactory, readonly world: IWorldStackDeployment) {}

    getAvatarFactory(): AvatarFactory {
        return this.world.avatarFactory;
    }

    getAvatarRegistry(): AvatarRegistry {
        return this.world.avatarRegistry;
    }

    async deploy(): Promise<void> {
       
    }

    
}