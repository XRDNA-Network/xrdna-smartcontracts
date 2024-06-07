import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { WorldFactoryUtils } from "./world/WorldFactoryUtils";
import { WorldRegistryUtils } from "./world/WorldRegistryUtils";
import { WorldUtils } from "./world/WorldUtils";
import { CompanyFactoryUtils } from "./company/CompanyFactoryUtils";
import { CompanyRegistryUtils } from "./company/CompanyRegistryUtils";
import { ethers } from "hardhat";
import { CompanyUtils } from "./company/CompanyMasterUtils";
import { RegistrarUtils } from "./RegistrarUtils";
import { Contract } from "ethers";
import { bigint } from "hardhat/internal/core/params/argumentTypes";
import { company } from "../typechain-types/contracts";
import { expect } from "chai";
import { VectorAddress, signVectorAddress } from "../src";



describe("Company Registration", () => {
    let signers: HardhatEthersSigner[];
    let worldUtils: WorldUtils;
    let registrarAdmin: HardhatEthersSigner;
    let registrarSigner: HardhatEthersSigner;
    let worldFactoryAdmin: HardhatEthersSigner;
    let worldRegistryAdmin: HardhatEthersSigner;
    let worldOwner: HardhatEthersSigner;
    let vectorAddressAuthority: HardhatEthersSigner;
    let registrarId: bigint;
    let companyFactoryUtils: CompanyFactoryUtils;
    let companyRegistryUtils: CompanyRegistryUtils;
    let companyUtils: CompanyUtils;
    let companyFactoryAdmin: HardhatEthersSigner;
    let companyRegistryAdmin: HardhatEthersSigner;
    
    before(async () => {
        worldUtils = new WorldUtils();
        signers = await ethers.getSigners();
        registrarAdmin = signers[0];
        registrarSigner = signers[1];
        worldFactoryAdmin = signers[2];
        worldRegistryAdmin = signers[3];
        worldOwner = signers[4];
        vectorAddressAuthority = signers[5];
        companyFactoryAdmin = signers[6];
        companyRegistryAdmin = signers[7];
        await worldUtils.deployWorldMaster({
            vectorAddressAuthority: vectorAddressAuthority.address,
            registrarAdmin,
            registrarSigner,
            worldFactoryAdmin,
            worldRegistryAdmin
        });

        const r = await worldUtils.registrarUtils?.registerRegistrar({
            admin: registrarAdmin,
            signer: registrarSigner.address,
            tokens: BigInt("1000000000000000000")
        });
        const regId = r?.registrarId;
        if(!regId) {
            throw new Error("Registrar not registered");
        }
        registrarId = regId;
        companyFactoryUtils = new CompanyFactoryUtils();
        companyRegistryUtils = new CompanyRegistryUtils(companyFactoryUtils);
        companyUtils = new CompanyUtils();

        await companyFactoryUtils.deployFactory({
            admins: signers
        });

        if (!companyFactoryUtils.factoryAddress) {
            throw new Error("WorldRegistry not deployed");
        }

        await companyRegistryUtils.deployCompanyRegistry({
            companyFactory: companyFactoryUtils.factoryAddress,
            worldRegistry: worldUtils.worldRegistryUtils?.worldRegistryAddress || "",
            admins: signers.map(s => s.address)
        });

        companyRegistryUtils.worldUtils = worldUtils;
        companyUtils.companyFactoryUtils = companyFactoryUtils;
        companyUtils.companyRegistryUtils = companyRegistryUtils;

    });

    it('should register a company', async () => {
        const baseVector = {
            x: "1",
            y: "1",
            z: "1",
            t: 0n,
            p: 0n,
            p_sub: 0n
        } as VectorAddress;

        const info = await companyUtils.companyRegistryUtils?.createCompany(
            {
                registrarSigner: registrarSigner,
                registrarId: registrarId.toString(),
                owner: worldOwner.address,
                name: "TestCompany",
                details: {
                    name: "",
                    baseVector: baseVector,
                    vectorAuthorizedSignature: await signVectorAddress(baseVector, vectorAddressAuthority);
                },
                tokensToOwner: true
            }
        )

        expect(info).to.not.be.undefined;
        // should be able to lookup a company
        const isCompany = await companyUtils.companyRegistryUtils?.lookupCompany(info?.companyAddress)
        expect(isCompany).to.be.true;

    });


        

    