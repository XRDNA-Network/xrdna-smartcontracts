import { ignition } from "hardhat";
import { ExperienceFactory, ExperienceRegistry } from "../../../src/experience";
import { IBasicDeployArgs, IDeployable } from "../IDeployable";
import { IExperienceStack } from "./IExperienceStack";
import ExperienceFactoryModule from "../../../ignition/modules/experience/ExperienceFactory.module";
import ExperienceRegistryModule from "../../../ignition/modules/experience/ExperienceRegistry.module";
import ExperienceModule from "../../../ignition/modules/experience/Experience.module";
import { StackCreatorFn } from "../StackFactory";


export class ExperienceStackImpl implements IExperienceStack, IDeployable {

    deployed: boolean = false;
    experienceFactory!: ExperienceFactory;
    experienceRegistry!: ExperienceRegistry;

    constructor(readonly factory: StackCreatorFn) {}

    getExperienceFactory(): ExperienceFactory {
        if(!this.deployed) {
            throw new Error("ExperienceStack not deployed");
        }

        return this.experienceFactory;
    }

    getExperienceRegistry(): ExperienceRegistry {
        if(!this.deployed) {
            throw new Error("ExperienceStack not deployed");
        }

        return this.experienceRegistry;
    }

    async deploy(args: IBasicDeployArgs): Promise<void> {
        if(this.deployed) {
            return;
        }

        await this._deployFactory(args);
        await this._deployRegistry(args);
        await this._deployMasterExperience(args);
        this.deployed = true;
    }

    async _deployFactory(args: IBasicDeployArgs): Promise<void> {
        const {experienceFactory} = await ignition.deploy(ExperienceFactoryModule);
        const address = await experienceFactory.getAddress();
        this.experienceFactory = new ExperienceFactory({
            address,
            admin: args.admin
        });
    }

    async _deployRegistry(args: IBasicDeployArgs): Promise<void> {
        const {experienceRegistry} = await ignition.deploy(ExperienceRegistryModule);
        const address = await experienceRegistry.getAddress();
        this.experienceRegistry = new ExperienceRegistry({
            address,
            admin: args.admin
        });
    }

    async _deployMasterExperience(args: IBasicDeployArgs): Promise<void> {
        await ignition.deploy(ExperienceModule);
    }
    
}