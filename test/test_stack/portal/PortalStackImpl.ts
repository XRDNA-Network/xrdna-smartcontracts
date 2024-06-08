import { ethers, ignition } from "hardhat";
import { PortalRegistry } from "../../../src/portal";
import { IBasicDeployArgs, IDeployable } from "../IDeployable";
import { IPortalStack } from "./IPortalStack";
import { StackFactory } from "../StackFactory";
import PortalRegistryModule from "../../../ignition/modules/portal/PortalRegistry.module";
import { IWorldStackDeployment } from "../world/WorldStackImpl";

export class PortalStackImpl implements IPortalStack, IDeployable {

    constructor(readonly factory: StackFactory, readonly world: IWorldStackDeployment) {}

    getPortalRegistry(): PortalRegistry {
        return this.world.portalRegistry;
    }


    async deploy(): Promise<void> {
        
    }
    
}