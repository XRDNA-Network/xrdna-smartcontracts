import { ignition } from "hardhat";
import { ExperienceFactory, ExperienceRegistry } from "../../../src/experience";
import { IBasicDeployArgs, IDeployable } from "../IDeployable";
import { IExperienceStack } from "./IExperienceStack";
import ExperienceFactoryModule from "../../../ignition/modules/experience/ExperienceFactory.module";
import ExperienceRegistryModule from "../../../ignition/modules/experience/ExperienceRegistry.module";
import ExperienceModule from "../../../ignition/modules/experience/Experience.module";
import { StackFactory } from "../StackFactory";
import { IWorldStackDeployment } from "../world/WorldStackImpl";


export class ExperienceStackImpl implements IExperienceStack, IDeployable {

   

    constructor(readonly factory: StackFactory, readonly world: IWorldStackDeployment) {}

    getExperienceFactory(): ExperienceFactory {
        return this.world.experienceFactory;
    }

    getExperienceRegistry(): ExperienceRegistry {
        return this.world.experienceRegistry;
    }

    async deploy(): Promise<void> {
        
    }
    
}