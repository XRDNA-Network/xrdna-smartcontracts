import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { ethers } from "hardhat";
import {abi as PortalRegistryABI} from "../../artifacts/contracts/portal/PortalRegistry.sol/PortalRegistry.json";
import { RegistrarUtils } from "../RegistrarUtils";


export class PortalRegistryUtils {
    portalRegistry: any = null;
    portalRegistryAddress: string | null = null;
    masterPortal: any = null;

    static portalRegistryAt(props: {
        address: string,
        admin: HardhatEthersSigner
    }): PortalRegistryUtils {
        const {address, admin} = props; 
        const utils = new PortalRegistryUtils(props.regUtils);
        utils.portalRegistry = new ethers.Contract(address, PortalRegistryABI, admin);
        utils.portalRegistryAddress = address;
        return utils;
    }

    constructor(
        readonly regUtils: RegistrarUtils,
    ) {
    }

    async deployPortalRegistry(props: {
        admin: HardhatEthersSigner,
        vectorAddressAuthority: string
    }) {
        if(this.portalRegistry) {
            return;
        }

        const PortalRegistry = await ethers.getContractFactory("PortalRegistry");
        const portalRegistry = await PortalRegistry.deploy(props.vectorAddressAuthority, this.regUtils.registryAddress, props.admin.address);
        const t = await portalRegistry.deploymentTransaction()?.wait();
        this.portalRegistryAddress = t?.contractAddress || "";
        console.log("PortalRegistry deployed at", this.portalRegistryAddress);
        this.portalRegistry = portalRegistry;
    }

    async setMasterPortal(portal: any) {
        this.masterPortal = portal;
    }

   async addPortal(props: {
    destination: string,
    fee: string,
   ) {
         if(!this.portalRegistry) {
              throw new Error("PortalRegistry not deployed");
         }
         const t = await this.portalRegistry.connect(this.portalAdmin).addPortal(props.destination, props.fee);
         await t.wait();
   }
}