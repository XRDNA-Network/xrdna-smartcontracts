import { expect } from "chai";
import { World } from "../typechain-types";
import { IEcosystem, IStackAdmins, StackFactory } from "./test_stack/StackFactory"
import {ethers} from "hardhat";
import { ERC721Asset } from "../src";

describe('Avatar', () => {
    let sf: StackFactory;
    let admins: IStackAdmins
    let world: World;
    let worldOwner: ethers.Signer;
    let avatarOwner: ethers.Signer;
    let companyOwner: ethers.Signer;
    let ecosystem: IEcosystem

    before(async () => {
        const signers = await ethers.getSigners();
        worldOwner = signers[1];
        companyOwner = signers[2];
        avatarOwner = signers[3];
        
        sf = new StackFactory({
            worldOwner: worldOwner,
            companyOwner: companyOwner,
            avatarOwner: avatarOwner
        });
        admins = sf.admins;
        const {world:w, worldRegistration: wr} = await sf.init();
        
        ecosystem = await sf.getEcosystem();
        
        
    });
    it('should register an avatar', async () => {
       const address = await ecosystem.avatar.address;
       expect(address).to.not.be.undefined;
    
    });

    it('should add a wearable to an avatar', async () => {
        const {avatar, testERC721, company} = ecosystem;
        
        const tokenId = await company.mintERC721(testERC721.assetAddress, avatar.address);

        const erc721 = new ERC721Asset({address: testERC721.assetAddress.toString(), provider: ethers.provider});

        const owner = await erc721.asset.ownerOf(tokenId.tokenId);

        expect(owner).to.equal(avatar.address);

        const wearable = await avatar.addWearable({
            asset: testERC721.assetAddress,
            tokenId: tokenId.tokenId
        });
        const r = await wearable.wait();
        if (!r) {
            throw new Error("Transaction failed with status 0");
        }
        
        expect(wearable).to.not.be.undefined;
        expect(r).to.not.be.null;
        expect(r.status).to.equal(1);
        const wearables = await avatar.getWearables();
        expect(wearables.find(w => w.tokenId == tokenId.tokenId)).to.not.be.undefined;
        
    });

    it('should remove a wearable from an avatar', async () => {
        const {avatar, testERC721} = ecosystem;
        const wearables = await avatar.getWearables();

        const wearable = wearables[0];
        const r = await avatar.removeWearable(wearable);
        expect(r).to.not.be.undefined;
        const r2 = await r.wait();
        if (!r2) {
            throw new Error("Transaction failed");
        }
        expect(r2.status).to.equal(1);
        const wearables2 = await avatar.getWearables();
        expect(wearables2.find(w => w.tokenId == wearable.tokenId)).to.be.undefined;
    });

    it("should add multiple wearables to an avatar", async () => {
        const {avatar, testERC721, company} = ecosystem;
        
        const {tokenId: tokenId1} = await company.mintERC721(testERC721.assetAddress, avatar.address);
        const {tokenId: tokenId2} = await company.mintERC721(testERC721.assetAddress, avatar.address);

        let t = await avatar.addWearable({
            asset: testERC721.assetAddress,
            tokenId: tokenId1
        });

        let r = await t.wait();
        if (!r) {
            throw new Error("Transaction failed");
        }
        expect(r.status).to.equal(1);
        t = await avatar.addWearable({
            asset: testERC721.assetAddress,
            tokenId: tokenId2
        });
        r = await t.wait();
        if (!r) {
            throw new Error("Transaction failed");
        }
        expect(r.status).to.equal(1);

        const wearables = await avatar.getWearables();
        expect(wearables.length).to.equal(2);
    });

    it("should remove wearable when multiple wearables configured for an avatar", async () => {
        const {avatar} = ecosystem;
        const wearables = await avatar.getWearables();
        expect(wearables.length).to.equal(2);
        const remainingToken = wearables[0].tokenId;
        const r = await avatar.removeWearable(wearables[1]);
        expect(r).to.not.be.undefined;
        const r2 = await r.wait();
        if (!r2) {
            throw new Error("Transaction failed");
        }
        expect(r2.status).to.equal(1);
        const wearables2 = await avatar.getWearables();
        expect(wearables2.length).to.equal(1);
        expect(wearables2[0].tokenId).to.equal(remainingToken);
    });

})