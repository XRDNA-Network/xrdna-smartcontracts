import { ethers, ignition } from "hardhat";
import { AvatarFactory } from "../../../src/avatar/AvatarFactory";
import { AvatarRegistry } from "../../../src/avatar/AvatarRegistry";
import { IBasicDeployArgs, IDeployable } from "../IDeployable";
import { StackCreatorFn, StackType } from "../StackFactory";
import { IAvatarStack } from "./IAvatarStack";
import { throwError } from "../../utils";
import { IWorldStack } from "../world/IWorldStack";
import { IPortalStack } from "../portal/IPortalStack";
import { IExperienceStack } from "../experience/IExperienceStack";
import AvatarFactoryModule from "../../../ignition/modules/avatar/AvatarFactory.module";
import AvatarRegistryModule from "../../../ignition/modules/avatar/AvatarRegistry.module";
import AvatarModule from "../../../ignition/modules/avatar/Avatar.module";


export interface IAvatarDeployArgs extends IBasicDeployArgs {}
export class AvatarStackImpl implements IAvatarStack, IDeployable {

    avatarFactory!: AvatarFactory;
    avatarRegistry!: AvatarRegistry;
    deployed: boolean = false;

    constructor(readonly factory: StackCreatorFn) {}

    getAvatarFactory(): AvatarFactory {
        if(!this.deployed) {
            throw new Error("AvatarStack not deployed");
        }

        return this.avatarFactory;
    }

    getAvatarRegistry(): AvatarRegistry {
        if(!this.deployed) {
            throw new Error("AvatarStack not deployed");
        }

        return this.avatarRegistry;
    }

    async deploy(args: IAvatarDeployArgs): Promise<void> {
        if(this.deployed) {
            return;
        }

        await this._deployFactory(args);
        await this._deployRegistry(args);
        await this._deployMasterAvatar(args);
        this.deployed = true;
    }

    async _deployFactory(args: IAvatarDeployArgs): Promise<void> {
        const {avatarFactory} = await ignition.deploy(AvatarFactoryModule);
        const address = await avatarFactory.getAddress();
        this.avatarFactory = new AvatarFactory({
            address,
            admin: args.admin
        });
    }

    async _deployRegistry(args: IAvatarDeployArgs): Promise<void> {
        const {avatarRegistry} = await ignition.deploy(AvatarRegistryModule);
        const address = await avatarRegistry.getAddress();
        this.avatarRegistry = new AvatarRegistry({
            address,
            admin: args.admin
        });
    }

    async _deployMasterAvatar(args: IAvatarDeployArgs): Promise<void> {

        const {avatarMasterCopy} = await ignition.deploy(AvatarModule);

    }
    
}