import { ethers } from "hardhat";
import { PortalRegistry } from "../../../src/portal";
import { IBasicDeployArgs, IDeployable } from "../IDeployable";
import { IPortalStack } from "./IPortalStack";
import { StackCreatorFn } from "../StackFactory";

export class PortalStackImpl implements IPortalStack, IDeployable {

    portalRegistry!: PortalRegistry;
    deployed: boolean = false;

    constructor(readonly factory: StackCreatorFn) {}

    getPortalRegistry(): PortalRegistry {
        if(!this.deployed) {
            throw new Error("PortalStack not deployed");
        }
        throw new Error("Method not implemented.");
    }


    async deploy(args: IBasicDeployArgs): Promise<void> {
        if(this.deployed) {
            return;
        }
        const f = await ethers.getContractFactory("PortalRegistry");
        const fInstance = await f.deploy(args.admin, [args.admin]);
        const t = await fInstance.deploymentTransaction()?.wait();
        this.portalRegistry = new PortalRegistry({
            address: t?.contractAddress || "",
            admin: args.admin
        });
        this.deployed = true;
    }
    
}