
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { AssetFactoryUtils } from "./AssetFactoryUtils";
import { ethers } from "hardhat";
import { AssetRegistryUtils } from "./AssetRegistryUtils";
import { AssetMasterUtils } from "./AssetMasterUtils";
import { AssetType, ERC20Asset, ERC20InitData } from "../../src";
import { expect } from "chai";

describe("ERC20", function() {

    let facUtils: AssetFactoryUtils;
    let regUtils: AssetRegistryUtils;
    let assetUtils: AssetMasterUtils;
    let signers: HardhatEthersSigner[];
    let admin: HardhatEthersSigner;
    let issuer: HardhatEthersSigner;
    let erc20: ERC20Asset;
    before(async () => {
        signers = await ethers.getSigners();
        admin = signers[0];
        issuer = signers[1];

        facUtils = new AssetFactoryUtils();
        await facUtils.deploy({assetFactoryAdmin: admin});
        regUtils = new AssetRegistryUtils();
        await regUtils.deploy({admin: admin, assetFactory: facUtils});

        assetUtils = new AssetMasterUtils();
        await assetUtils.deploy({factory: facUtils, registry: regUtils, assetIssuer: issuer});
    
        const initData: ERC20InitData = {
            name: "USDC",
            symbol: "USDC",
            decimals: 6,
            issuer: issuer.address,
            originChainAddress: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
            originChainId: 1n,
            totalSupply: 100000000n
        }
        const reg = regUtils.toWrapper();
        const r = await reg.registerAsset(AssetType.ERC20, initData);
        expect(r).to.not.be.null;
        expect(r.assetAddress).to.not.be.empty;
        console.log("New asset deployed to", r.assetAddress);
        const wrapper = new ERC20Asset({address: r.assetAddress, admin: issuer});
        const name = await wrapper.name();
        expect(name).to.equal(initData.name);
        erc20 = wrapper;
    });

    it("Should allow issuer to mint assets", async () => {
        const amount = 1000n;
        const w = ethers.Wallet.createRandom();
        const to = w.address;
        await erc20.mint(to, amount);
        const balance = await erc20.balanceOf(to);
        expect(balance).to.equal(amount);
    });

    it("Should NOT allow non-issuer to mint assets", async () => {
        const e = new ERC20Asset({address: erc20.address, admin: signers[3]});
        const amount = 1000n;
        const w = ethers.Wallet.createRandom();
        const to = w.address;
        try {
            await e.mint(to, amount);
        } catch(err:any) {
            expect(err.message).to.contain("only issuer allowed");
        }
    });

    it("Should allow for upgrading asset contract", async () => {
        const initData: ERC20InitData = {
            name: "USDC2",
            symbol: "USDC2",
            decimals: 6,
            issuer: issuer.address,
            originChainAddress: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
            originChainId: 1n,
            totalSupply: 100000000n
        }
        const reg = regUtils.toWrapper();
        const r2 = await reg.upgradeAsset({
            assetAddress: erc20.address, 
            assetType: AssetType.ERC20, 
            initData,
            assetIssuer: issuer
        });
        expect(r2).to.not.be.null;
        expect(r2.assetAddress).to.not.be.empty;
        console.log("Upgraded asset deployed to", r2.assetAddress);
        const didUpgrade = await erc20.upgraded();
        expect(didUpgrade).to.be.true;
        let isReg = await reg.isRegisteredAsset(erc20.address);
        expect(isReg).to.be.false;
        isReg = await reg.isRegisteredAsset(r2.assetAddress);
        expect(isReg).to.be.true;
        erc20 = new ERC20Asset({address: r2.assetAddress, admin: issuer});
    });

    it("Should not allow upgrade from non-issuer", async () => {
        const initData: ERC20InitData = {
            name: "USDC3",
            symbol: "USDC3",
            decimals: 6,
            issuer: issuer.address,
            originChainAddress: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
            originChainId: 1n,
            totalSupply: 100000000n
        }
        const reg = regUtils.toWrapper();
        try {
            await reg.upgradeAsset({
                assetAddress: erc20.address, 
                assetType: AssetType.ERC20, 
                initData,
                assetIssuer: signers[3]
            });
        } catch(err:any) {
            expect(err.message).to.contain("not the asset issuer");
        }
    });
})