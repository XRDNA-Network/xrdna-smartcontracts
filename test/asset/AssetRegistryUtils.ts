import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { AssetFactoryUtils } from "./AssetFactoryUtils";
import { ethers } from "hardhat";
import { AssetRegistry } from "../../src";
import { Signer } from "ethers";

function throwError(message: string): never {
    throw new Error(message);
}

export class AssetRegistryUtils {
    assetRegistry: any = null;
    assetRegistryAddress: string | null = null;
    admin: HardhatEthersSigner | null = null;

    async deploy(props: {
        admin: HardhatEthersSigner,
        assetFactory: AssetFactoryUtils
    }) {
        if(this.assetRegistry) {
            return;
        }

        this.admin = props.admin;
        const AssetRegistry = await ethers.getContractFactory("AssetRegistry");
        const assetRegistry = await AssetRegistry.deploy([props.admin.address], props.assetFactory.factoryAddress || throwError("AssetFactory not deployed"));
        const t = await assetRegistry.deploymentTransaction()?.wait();
        this.assetRegistryAddress = t?.contractAddress || "";
        console.log("AssetRegistry deployed at", this.assetRegistryAddress);
        this.assetRegistry = assetRegistry;

        const f = props.assetFactory.toWrapper();
        await f.setAssetRegistry(this.assetRegistryAddress);
    }

    toWrapper(): AssetRegistry {
        if(!this.assetRegistry) {
            throw new Error("AssetRegistry not deployed");
        }
        return new AssetRegistry({
            admin: this.admin as Signer,
            address: this.assetRegistryAddress as string
        });
    }
}