import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../Libraries.module";
import {abi as ABI} from '../../../artifacts/contracts/ext-registry/ICoreExtensionRegistry.sol/ICoreExtensionRegistry.json';
import { XRDNASigners } from "../../../src";
import { network } from "hardhat";

export const abi = ABI;

export default buildModule("ExtensionRegistryModule", (m) => {

    const libs = m.useModule(LibrariesModule);
    const xrdna = new XRDNASigners();
    const config = xrdna.deployment[network.config.chainId || 55555];
    const owner = config.extensionRegistryAdmin;
    const others = config.extensionRegistryOtherAdmins;
    

    //make sure to use proxy addresses, not implementation addresses
    const args = {
        owner, 
        admins: others
    }
    const r = m.contract("CoreExtensionRegistry", [args], {
        libraries: {
            LibAccess: libs.LibAccess,
            LibCoreExtensionRegistry: libs.libCoreExtensionRegistry
        },
        after: [
            libs.LibAccess,
        ]
    });
    return {
        extensionsRegistry: r
    }
});