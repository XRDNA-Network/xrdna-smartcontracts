import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { ethers } from "hardhat";
import { AssetFactory } from "../../src";
import { AssetFactoryUtils } from "./AssetFactoryUtils";
import { AssetRegistryUtils } from "./AssetRegistryUtils";
import { throwError } from "../utils";

export class AssetMasterUtils {
    erc20: any;
    erc721: any;
    erc20Address: string | null = null;
    erc721Address: string | null = null;
    assetIssuer: HardhatEthersSigner | null = null;

    async deploy(
        props: {
            factory: AssetFactoryUtils,
            registry: AssetRegistryUtils,
            assetIssuer: HardhatEthersSigner
        }
    ) {
        if(this.erc20) {
            return;
        }

        this.assetIssuer = props.assetIssuer;
        const ERC20Asset = await ethers.getContractFactory("NonTransferableERC20Asset");
        const asset = await ERC20Asset.deploy(props.factory.factoryAddress || throwError("Factory not deployed"), props.registry.assetRegistryAddress || throwError("Registry not deployed"));
        let t = await asset.deploymentTransaction()?.wait();
        this.erc20Address = t?.contractAddress || "";
        console.log("ERC20 master deployed at", this.erc20Address);
        this.erc20 = asset;

        const ERC721Asset = await ethers.getContractFactory("NonTransferableERC721Asset");
        const asset721 = await ERC721Asset.deploy(props.factory.factoryAddress || throwError("Factory not deployed"), props.registry.assetRegistryAddress || throwError("Registry not deployed"));
        t = await asset721.deploymentTransaction()?.wait();
        this.erc721Address = t?.contractAddress || "";
        console.log("ERC721 master deployed at", this.erc721Address);
        this.erc721 = asset721;

        const wrapper = props.factory.toWrapper();
        await wrapper.setERC20Implementation(this.erc20Address);
        await wrapper.setERC721Implementation(this.erc721Address);
    }
}