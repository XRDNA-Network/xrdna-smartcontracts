import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { AssetFactoryUtils } from "./AssetFactoryUtils";
import { ethers } from "hardhat";
import { AssetRegistryUtils } from "./AssetRegistryUtils";

describe("AssetRegistry", function() {

    let facUtils: AssetFactoryUtils;
    let regUtils: AssetRegistryUtils;
    let signers: HardhatEthersSigner[];
    let admin: HardhatEthersSigner;
    before(async () => {
        signers = await ethers.getSigners();
        admin = signers[0];
        facUtils = new AssetFactoryUtils();
        await facUtils.deploy({assetFactoryAdmin: admin});
        regUtils = new AssetRegistryUtils();
        await regUtils.deploy({admin: admin, assetFactory: facUtils});
    });

    it("Should deploy", async () => {});
})