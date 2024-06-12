import { expect } from "chai";
import { World } from "../typechain-types";
import { IEcosystem, IStackAdmins, StackFactory } from "./test_stack/StackFactory"
import {ethers} from "hardhat";
import { ERC721Asset } from "../src";

describe('Avatar', () => {
    let sf: StackFactory;
    let admins: IStackAdmins
    let world: World;
    let registrarAdmin: ethers.Signer;
    let registrarSigner: ethers.Signer;
    let worldRegistryAdmin: ethers.Signer;
    let worldOwner: ethers.Signer;
    let avatarOwner: ethers.Signer;
    let companyOwner: ethers.Signer;
    let ecosystem: IEcosystem

    before(async () => {
        const signers = await ethers.getSigners();
        registrarAdmin = signers[0];
        registrarSigner = signers[0];
        worldRegistryAdmin = signers[0];
        worldOwner = signers[1];
        companyOwner = signers[2];
        avatarOwner = signers[3];
        admins = {
            assetRegistryAdmin: signers[0],
            avatarRegistryAdmin: signers[0],
            companyRegistryAdmin: signers[0],
            experienceRegistryAdmin: signers[0],
            portalRegistryAdmin: signers[0],
            registrarAdmin,
            registrarSigner,
            worldRegistryAdmin,
            worldOwner,
            avatarOwner
        }
        sf = new StackFactory(admins);
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
        
    })

})