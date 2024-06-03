import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { ethers } from "hardhat";
import { AssetRegistryUtils } from "../AssetRegistryUtils";
import { AssetRegistry } from "../../../src";

export class FilterByWorldUtils {
    filter: any;
    filterAddress: string | null = null;
    filterAdmin: HardhatEthersSigner | null = null;

    async deploy(
        props: {
            filterAdmin: HardhatEthersSigner,
            whitelist: string[],
            assetRegistry: AssetRegistry,
            assetAddress: string,
            assetIssuer: HardhatEthersSigner
        }
    ) {
        if(this.filter) {
            return;
        }

        this.filterAdmin = props.filterAdmin;
        const Factory = await ethers.getContractFactory("FilterByWorld");
        const factory = await Factory.deploy(this.filterAdmin.address, props.whitelist);
        const t = await factory.deploymentTransaction()?.wait();
        this.filterAddress = t?.contractAddress || "";
        console.log("FilterByWorld deployed at", this.filterAddress);
        this.filter = factory;
        const r = props.assetRegistry;
        await r.addAssetCondition({
            assetAddress: props.assetAddress, 
            condition: this.filterAddress,
            assetIssuer: props.assetIssuer
        });

    }
}