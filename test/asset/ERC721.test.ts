
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { AssetFactoryUtils } from "./AssetFactoryUtils";
import { ethers } from "hardhat";
import { AssetRegistryUtils } from "./AssetRegistryUtils";
import { AssetMasterUtils } from "./AssetMasterUtils";
import { AssetType, ERC721Asset, ERC721InitData } from "../../src";
import { expect } from "chai";
import { FilterByWorldUtils } from "./sample_conditions/FilterByWorldUtils";

describe("ERC721", function() {

    let facUtils: AssetFactoryUtils;
    let regUtils: AssetRegistryUtils;
    let assetUtils: AssetMasterUtils;
    let signers: HardhatEthersSigner[];
    let admin: HardhatEthersSigner;
    let issuer: HardhatEthersSigner;
    let erc721: ERC721Asset;
    let worldAddress: string;
    let initData: ERC721InitData;

    before(async () => {
        signers = await ethers.getSigners();
        admin = signers[0];
        issuer = signers[1];
        worldAddress = signers[2].address;

        facUtils = new AssetFactoryUtils();
        await facUtils.deploy({assetFactoryAdmin: admin});
        regUtils = new AssetRegistryUtils();
        await regUtils.deploy({admin: admin, assetFactory: facUtils});

        assetUtils = new AssetMasterUtils();
        await assetUtils.deploy({factory: facUtils, registry: regUtils, assetIssuer: issuer});
    
        initData = {
            name: "Bored Ape Yaucht Club",
            symbol: "BAYC",
            issuer: issuer.address,
            originChainAddress: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
            originChainId: 1n,
            baseURI: "https://boredapeyachtclub.com/"
        }
        
        const reg = regUtils.toWrapper();
        const r = await reg.registerAsset(AssetType.ERC721, initData);
        expect(r).to.not.be.null;
        expect(r.assetAddress).to.not.be.empty;
        console.log("New asset deployed to", r.assetAddress);
        const wrapper = new ERC721Asset({address: r.assetAddress, admin: issuer});
        const name = await wrapper.name();
        expect(name).to.equal(initData.name);
        erc721 = wrapper;

        const filterUtils = new FilterByWorldUtils();
        await filterUtils.deploy({
            filterAdmin: issuer,
            whitelist: [worldAddress],
            assetRegistry: reg,
            assetAddress: erc721.address,
            assetIssuer: issuer
        });
    });

    it("Should allow issuer to mint assets", async () => {
        const w = ethers.Wallet.createRandom();
        const to = w.address;
        const r = await erc721.mint(to);
        const balance = await erc721.balanceOf(to);
        expect(balance).to.equal(1);
        expect(r.tokenId).to.equal(1);
        const uri = await erc721.tokenURI(r.tokenId);
        expect(uri).to.equal("https://boredapeyachtclub.com/1");
    });

    it("Should NOT allow non-issuer to mint assets", async () => {
        const e = new ERC721Asset({address: erc721.address, admin: signers[3]});
        const w = ethers.Wallet.createRandom();
        const to = w.address;
        try {
            await e.mint(to);
        } catch(err:any) {
            expect(err.message).to.contain("only issuer allowed");
        }
    });

    it("Should evaluate conditions", async () => {
        const reg = regUtils.toWrapper();
        let r = await reg.canUseAsset({
            assetAddress: erc721.address,
            worldAddress: worldAddress,
            companyAddress: signers[4].address,
            experienceAddress: signers[5].address
        });
        expect(r).to.be.true;
        r = await reg.canUseAsset({
            assetAddress: erc721.address,
            worldAddress: signers[9].address,
            companyAddress: signers[4].address,
            experienceAddress: signers[5].address
        });
        expect(r).to.be.false;
    });

    it("Registry should show token exists by original address and chain", async () => {
        const reg = regUtils.toWrapper();
        const exists = await reg.assetExists(initData.originChainAddress, initData.originChainId);
        expect(exists).to.be.true;
        const not = await reg.assetExists(initData.originChainAddress, 55n);
        expect(not).to.be.false;
    });
})