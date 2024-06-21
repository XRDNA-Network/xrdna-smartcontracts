import {
    time,
    loadFixture,
  } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { ethers } from "hardhat";
import { HardhatTestKeys } from "./HardhatTestKeys";
import { expect } from "chai";

describe("XRDNAGasToken", () => {

    async function deployToken() {
        const w = new ethers.Wallet(HardhatTestKeys[0].key, ethers.provider);
        const XRDNAGasToken = await ethers.getContractFactory("XRDNAGasToken");
        const token = await XRDNAGasToken.deploy(HardhatTestKeys[0].address, [HardhatTestKeys[1].address]);
        return token;
    }

    it("should deploy", async () => {
        const token = await loadFixture(deployToken);
        const r = await token.deploymentTransaction()?.wait();
        expect(r).to.not.be.null;
        expect(r?.contractAddress).to.not.be.null;
    });

    it("should mint", async () => {
        const token = await loadFixture(deployToken);
        const signers = await ethers.getSigners();
        const r = await token.connect(signers[1]).mint(HardhatTestKeys[2].address, 100);
        const b = await token.balanceOf(HardhatTestKeys[2].address);
        expect(r).to.not.be.null;
        expect(b.toString()).to.equal("100");
    });

});