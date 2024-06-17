import { ignition } from "hardhat";
import {  ERC20AssetFactory, ERC20AssetRegistry, ERC721AssetFactory, ERC721AssetRegistry, MultiAssetRegistry, RegistrarRegistry, WorldFactory, WorldRegistry } from "../../../src";
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
    erc20AssetRegistry: ERC20AssetRegistry;
    erc20AssetFactory: ERC20AssetFactory;
    erc721AssetRegistry: ERC721AssetRegistry;
    erc721AssetFactory: ERC721AssetFactory;
    multiAssetRegistry: MultiAssetRegistry;
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
                erc20AssetFactory: new ERC20AssetFactory({
                    address: await mod.erc20Factory.getAddress(),
                    admin: this.factory.admins.assetRegistryAdmin,
                    logParser: this.factory.logParser
                }),
                erc20AssetRegistry: new ERC20AssetRegistry({
                    address: await mod.erc20Registry.getAddress(),
                    admin: this.factory.admins.assetRegistryAdmin,
                    logParser: this.factory.logParser
                }),
                erc721AssetFactory: new ERC721AssetFactory({
                    address: await mod.erc721Factory.getAddress(),
                    admin: this.factory.admins.assetRegistryAdmin,
                    logParser: this.factory.logParser
                }),
                erc721AssetRegistry: new ERC721AssetRegistry({
                    address: await mod.erc721Registry.getAddress(),
                    admin: this.factory.admins.assetRegistryAdmin,
                    logParser: this.factory.logParser
                }),
                multiAssetRegistry: new MultiAssetRegistry({
                    address: await mod.multiAssetRegistry.getAddress(),
                    admin: this.factory.admins.assetRegistryAdmin,
                    logParser: this.factory.logParser
                }),
                avatarFactory: new AvatarFactory({
                    address: await mod.avatarFactory.getAddress(),
                    admin: this.factory.admins.avatarRegistryAdmin,
                    logParser: this.factory.logParser
                }),
                avatarRegistry: new AvatarRegistry({
                    address: await mod.avatarRegistry.getAddress(),
                    admin: this.factory.admins.avatarRegistryAdmin,
                    logParser: this.factory.logParser
                }),
                companyFactory: new CompanyFactory({
                    address: await mod.companyFactory.getAddress(),
                    admin: this.factory.admins.companyRegistryAdmin,
                    logParser: this.factory.logParser
                }),
                companyRegistry: new CompanyRegistry({
                    address: await mod.companyRegistry.getAddress(),
                    admin: this.factory.admins.companyRegistryAdmin,
                    logParser: this.factory.logParser
                }),
                experienceFactory: new ExperienceFactory({
                    address: await mod.experienceFactory.getAddress(),
                    admin: this.factory.admins.experienceRegistryAdmin,
                    logParser: this.factory.logParser
                }),
                experienceRegistry: new ExperienceRegistry({
                    address: await mod.experienceRegistry.getAddress(),
                    admin: this.factory.admins.experienceRegistryAdmin,
                    logParser: this.factory.logParser
                }),
                portalRegistry: new PortalRegistry({
                    address: await mod.portalRegistry.getAddress(),
                    admin: this.factory.admins.portalRegistryAdmin,
                    logParser: this.factory.logParser
                }),
                registrarRegistry: new RegistrarRegistry({
                    address: await mod.registrarRegistry.getAddress(),
                    admin: this.factory.admins.registrarAdmin,
                    logParser: this.factory.logParser
                }),
                worldFactory: new WorldFactory({
                    address: await mod.worldFactory.getAddress(),
                    admin: this.factory.admins.worldRegistryAdmin,
                    logParser: this.factory.logParser
                }),
                worldRegistry: new WorldRegistry({
                    address: await mod.worldRegistry.getAddress(),
                    admin: this.factory.admins.worldRegistryAdmin,
                    logParser: this.factory.logParser
                })
            } as IWorldStackDeployment;
            this.worldFactory = r.worldFactory;
            this.worldRegistry = r.worldRegistry;
            this.result = r;
            this.deployed = true;
            return r;
        }

}