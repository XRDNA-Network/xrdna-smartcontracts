import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { ethers } from "hardhat";
import { AssetFactory } from "../../src";
import { Signer } from "ethers";

export class AssetFactoryUtils {
    factory: any;
    factoryAddress: string | null = null;
    factoryAdmin: HardhatEthersSigner | null = null;

    async deploy(
        props: {
            assetFactoryAdmin: HardhatEthersSigner
        }
    ) {
        if(this.factory) {
            return;
        }

        this.factoryAdmin = props.assetFactoryAdmin;
        const Factory = await ethers.getContractFactory("AssetFactory");
        const factory = await Factory.deploy(props.assetFactoryAdmin, [props.assetFactoryAdmin.address]);
        const t = await factory.deploymentTransaction()?.wait();
        this.factoryAddress = t?.contractAddress || "";
        console.log("AssetFactory deployed at", this.factoryAddress);
        this.factory = factory;
    }

    toWrapper(): AssetFactory {
        if(!this.factory) {
            throw new Error("AssetFactory not deployed");
        }
        return new AssetFactory({
            admin: this.factoryAdmin as Signer,
            address: this.factoryAddress as string
        });
    }
}