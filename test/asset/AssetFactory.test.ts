import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { AssetFactoryUtils } from "./AssetFactoryUtils";
import { ethers } from "hardhat";
import { AssetFactory } from "../../src";

describe("AssetFactory", function() {

    let facUtils: AssetFactoryUtils;
    let factory: AssetFactory;
    let signers: HardhatEthersSigner[];
    let factoryAdmin: HardhatEthersSigner;
    before(async () => {
        signers = await ethers.getSigners();
        factoryAdmin = signers[0];
        facUtils = new AssetFactoryUtils();
        await facUtils.deploy({assetFactoryAdmin: factoryAdmin});
        factory = facUtils.toWrapper();
    });

    it("Should deploy", async () => {});
})