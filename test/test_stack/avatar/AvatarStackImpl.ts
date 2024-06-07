import { ethers } from "hardhat";
import { AvatarFactory } from "../../../src/avatar/AvatarFactory";
import { AvatarRegistry } from "../../../src/avatar/AvatarRegistry";
import { IBasicDeployArgs, IDeployable } from "../IDeployable";
import { StackCreatorFn, StackType } from "../StackFactory";
import { IAvatarStack } from "./IAvatarStack";
import { throwError } from "../../utils";
import { IWorldStack } from "../world/IWorldStack";
import { IPortalStack } from "../portal/IPortalStack";
import { IExperienceStack } from "../experience/IExperienceStack";


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
        const f = await ethers.getContractFactory("AvatarFactory");
        const fInstance = await f.deploy(args.admin, [args.admin]);
        const t = await fInstance.deploymentTransaction()?.wait();
        this.avatarFactory = new AvatarFactory({
            address: t?.contractAddress || throwError("AvatarFactory deployment failed"),
            admin: args.admin
        });
    }

    async _deployRegistry(args: IAvatarDeployArgs): Promise<void> {
        const f = await ethers.getContractFactory("AvatarRegistry");
        const wStack:IWorldStack = await this.factory(StackType.WORLD);
        const cArgs = {
            mainAdmin: args.admin,
            admins: [await args.admin.getAddress()],
            avatarFactory: this.avatarFactory.address,
            worldRegistry: wStack.getWorldRegistry().address
        }
        const fInstance = await f.deploy(cArgs);
        const t = await fInstance.deploymentTransaction()?.wait();
        this.avatarRegistry = new AvatarRegistry({
            address: t?.contractAddress || throwError("AvatarRegistry deployment failed"),
            admin: args.admin
        });
    }

    async _deployMasterAvatar(args: IAvatarDeployArgs): Promise<void> {

        const expReg: IExperienceStack = await this.factory(StackType.EXPERIENCE);
        const portalReg: IPortalStack = await this.factory(StackType.PORTAL);
        const cArgs = {
            avatarFactory: this.avatarFactory.address,
            avatarRegistry: this.avatarRegistry.address,
            experienceRegistry: expReg.getExperienceRegistry().address,
            portalRegistry: portalReg.getPortalRegistry().address,
            companyRegistry: companyReg.companyRegistry
        }
    }
    
}