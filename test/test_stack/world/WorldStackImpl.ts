import { ignition } from "hardhat";
import WorldFactoryModule from "../../../ignition/modules/world/WorldFactory.module";
import { World, WorldFactory, WorldRegistry } from "../../../src";
import { IBasicDeployArgs, IDeployable } from "../IDeployable";
import { StackCreatorFn } from "../StackFactory";
import { IWorldStack } from "./IWorldStack";
import WorldRegistryModule from "../../../ignition/modules/world/WorldRegistry.module";
import WorldModule from "../../../ignition/modules/world/World.module";
import { Signer } from "ethers";

export class WorldStackImpl implements IWorldStack, IDeployable {
    
        worldFactory!: WorldFactory;
        worldRegistry!: WorldRegistry;
        deployed: boolean = false;
    
        constructor(readonly factory: StackCreatorFn) {}
    
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

    
        async deploy(args: IBasicDeployArgs): Promise<void> {
            if(this.deployed) {
                return;
            }
            await this._deployFactory(args);
            await this._deployRegistry(args);
            await this._deployMasterWorld(args);
            this.deployed = true;
        }
    
        async _deployFactory(args: IBasicDeployArgs): Promise<void> {
            const {worldFactory} = await ignition.deploy(WorldFactoryModule);
            const address = await worldFactory.getAddress();
            this.worldFactory = new WorldFactory({
                address,
                factoryAdmin: args.admin
            });
        }

        async _deployRegistry(args: IBasicDeployArgs): Promise<void> {
            const {worldRegistry} = await ignition.deploy(WorldRegistryModule);
            const address = await worldRegistry.getAddress();
            this.worldRegistry = new WorldRegistry({
                address,
                admin: args.admin
            });
        }

        async _deployMasterWorld(args: IBasicDeployArgs): Promise<void> {
            await ignition.deploy(WorldModule);
        }

}