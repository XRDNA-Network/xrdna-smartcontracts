import { ignition } from "hardhat";
import { RegistrarRegistry, Registrar } from "../../../src";
import { IBasicDeployArgs, IDeployable } from "../IDeployable";
import { IRegistrarStack } from "./IRegistrarStack";
import RegistrarRegistryModule from "../../../ignition/modules/RegistrarRegistry.module";
import { StackFactory } from "../StackFactory";
import { Signer } from "ethers";
import { IWorldStackDeployment } from "../world/WorldStackImpl";

export interface IRegistrarStackOpts {
    registrarAdmin: Signer;
}

export class RegistrarStackImpl implements IRegistrarStack, IDeployable {
    

    constructor(readonly factory: StackFactory, readonly world: IWorldStackDeployment) {
    }

    getRegistrarRegistry(): RegistrarRegistry {
        return this.world.registrarRegistry;
    }

    async deploy(): Promise<void> {
        
    }
    
}