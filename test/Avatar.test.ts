import { expect } from "chai";
import { World } from "../typechain-types";
import { IEcosystem, IStackAdmins, StackFactory } from "./test_stack/StackFactory"
import {ethers} from "hardhat" 
// import {ethers } from "ethers"

import { ERC721Asset } from "../src";
import exp from "constants";
import { hexlify } from "ethers";

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

        const erc721 = new ERC721Asset({address: testERC721.assetAddress.toString(), provider: ethers.provider, logParser: sf.logParser});

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

    it("should not allow adding a wearable that is already added", async () => {
        const {avatar, testERC721} = ecosystem;
        const wearables = await avatar.getWearables();
        const wearable = wearables[0];
        const t = avatar.addWearable({
            asset: testERC721.assetAddress,
            tokenId: wearable.tokenId
        });
        const message = await t.catch((reason) => {
            return reason.message
        });
        expect(message).to.contain('Wearable already in list')
    
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

    it('should not allow adding non registered wearables', async () => {
        const {avatar} = ecosystem;
        const TestERC721Factory = await ethers.getContractFactory("TestERC721");
        const deploy = await TestERC721Factory.deploy('Test2', 'T2');
        const testERC721 = await deploy.waitForDeployment();
        const txn = await testERC721.mint(avatar.address, 2);
        const r = await txn.wait();
        if (!r) {
            throw new Error("Transaction failed");
        }
        expect(r.status).to.equal(1);
        
        
        const t = avatar.addWearable({
            asset: await testERC721.getAddress(),
            tokenId: 2n
        });
        const message = await t.catch((reason) => {
            return reason.message
        });
        expect(message).to.contain('wearable asset not registered');
    });

    it('revoked wearables should not be returned in getWearables', async () => {
        const {avatar, testERC721, company} = ecosystem;

        const tokenId = await company.mintERC721(testERC721.assetAddress, avatar.address);
        
        const wearable = await avatar.addWearable({
            asset: testERC721.assetAddress,
            tokenId: tokenId.tokenId
        });
        const r = await wearable.wait();
        if (!r) {
            throw new Error("Transaction failed");
        }
        expect(r.status).to.equal(1);
        const wearables = await avatar.getWearables();
        const isWearing = wearables.find(w => w.tokenId == tokenId.tokenId);
        expect(isWearing).to.not.be.undefined;

        const revoke = await company.revoke(testERC721.assetAddress.toString(), avatar.address, tokenId.tokenId);
        const r2 = await revoke.wait();
        if (!r2) {
            throw new Error("Transaction failed");
        }

        expect(r2.status).to.equal(1);
        const wearables2 = await avatar.getWearables();
        const isWearing2 = wearables2.find(w => w.tokenId == tokenId.tokenId);
        expect(isWearing2).to.be.undefined;
    })

    

})
