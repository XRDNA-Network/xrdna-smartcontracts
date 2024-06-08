import { ignition } from "hardhat";
import {  AssetFactory, AssetRegistry, RegistrarRegistry, WorldFactory, WorldRegistry } from "../../../src";
import {  IDeployable } from "../IDeployable";
import {  StackFactory } from "../StackFactory";
import { IWorldStack } from "./IWorldStack";
import WorldModule from "../../../ignition/modules/world/World.module";
import { AvatarRegistry } from "../../../src/avatar/AvatarRegistry";
import { AvatarFactory } from "../../../src/avatar/AvatarFactory";
import { CompanyRegistry } from "../../../src/company/CompanyRegistry";
import { CompanyFactory } from "../../../src/company/CompanyFactory";
import { ExperienceFactory, ExperienceRegistry } from "../../../src/experience";
import { PortalRegistry } from "../../../src/portal";

export interface IWorldStackDeployment {
    assetRegistry: AssetRegistry;
    assetFactory: AssetFactory;
    avatarRegistry: AvatarRegistry;
    avatarFactory: AvatarFactory;
    companyRegistry: CompanyRegistry;
    companyFactory: CompanyFactory;
    experienceRegistry: ExperienceRegistry;
    experienceFactory: ExperienceFactory;
    portalRegistry: PortalRegistry;
    registrarRegistry: RegistrarRegistry;
    worldFactory: WorldFactory;
    worldRegistry: WorldRegistry;
}
export class WorldStackImpl implements IWorldStack, IDeployable {
    
        worldFactory!: WorldFactory;
        worldRegistry!: WorldRegistry;
        deployed: boolean = false;
        result?: IWorldStackDeployment;
    
        constructor(readonly factory: StackFactory) {}
    
        getWorldFactory(): WorldFactory {
            if(!this.deployed) {
                throw new Error("WorldStack not deployed");
            }
    
            return this.worldFactory;
        }

        getWorldRegistry(): WorldRegistry {
            if(!this.deployed) {
                throw new Error("WorldStack not deployed");
            }
    
            return this.worldRegistry;
        }

    
        async deploy(): Promise<IWorldStackDeployment> {
            if(this.deployed) {
                return this.result!;
            }
            
            const mod = await ignition.deploy(WorldModule);
            const r = {
                assetFactory: new AssetFactory({
                    address: await mod.assetFactory.getAddress(),
                    admin: this.factory.admins.assetRegistryAdmin
                }),
                assetRegistry: new AssetRegistry({
                    address: await mod.assetRegistry.getAddress(),
                    admin: this.factory.admins.assetRegistryAdmin
                }),
                avatarFactory: new AvatarFactory({
                    address: await mod.avatarFactory.getAddress(),
                    admin: this.factory.admins.avatarRegistryAdmin
                }),
                avatarRegistry: new AvatarRegistry({
                    address: await mod.avatarRegistry.getAddress(),
                    admin: this.factory.admins.avatarRegistryAdmin
                }),
                companyFactory: new CompanyFactory({
                    address: await mod.companyFactory.getAddress(),
                    admin: this.factory.admins.companyRegistryAdmin
                }),
                companyRegistry: new CompanyRegistry({
                    address: await mod.companyRegistry.getAddress(),
                    admin: this.factory.admins.companyRegistryAdmin
                }),
                experienceFactory: new ExperienceFactory({
                    address: await mod.experienceFactory.getAddress(),
                    admin: this.factory.admins.experienceRegistryAdmin
                }),
                experienceRegistry: new ExperienceRegistry({
                    address: await mod.experienceRegistry.getAddress(),
                    admin: this.factory.admins.experienceRegistryAdmin
                }),
                portalRegistry: new PortalRegistry({
                    address: await mod.portalRegistry.getAddress(),
                    admin: this.factory.admins.portalRegistryAdmin
                }),
                registrarRegistry: new RegistrarRegistry({
                    address: await mod.registrarRegistry.getAddress(),
                    admin: this.factory.admins.registrarAdmin
                }),
                worldFactory: new WorldFactory({
                    address: await mod.worldFactory.getAddress(),
                    admin: this.factory.admins.worldRegistryAdmin
                }),
                worldRegistry: new WorldRegistry({
                    address: await mod.worldRegistry.getAddress(),
                    admin: this.factory.admins.worldRegistryAdmin
                })
            } as IWorldStackDeployment;
            this.worldFactory = r.worldFactory;
            this.worldRegistry = r.worldRegistry;
            this.result = r;
            this.deployed = true;
            return r;
        }

}