import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { XRDNASigners } from "../../../src";
import {ethers, network} from 'hardhat';
import LibrariesModule from "../libraries/Libraries.module";

export default buildModule("Core", (m) => {

        
        const xrdna = new XRDNASigners();
        const config = xrdna.deployment[network.config.chainId || 55555];
        const acct = config.registrarRegistryAdmin;
        const others = config.registrarRegistryOtherAdmins;
        const args = {
            owner: acct,
            otherAdmins: others
        }
        const libs = m.useModule(LibrariesModule);
        const core = m.contract("CoreExtensionRegistry", [args], {
            libraries: {
                LibCoreExtensionRegistry: libs.LibCoreExtensionRegistry
            },
            after: [
                libs.LibAccess,
                libs.LibCoreExtensionRegistry,
                libs.LibExtensions
            ]
        });
        return {
            coreExtensionRegistry: core
        }
});