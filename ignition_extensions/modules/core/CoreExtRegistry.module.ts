import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { XRDNASigners } from "../../../src";
import {network} from 'hardhat';
import LibrariesModule from "../libraries/Libraries.module";
import {abi as ABI} from '../../../artifacts/contracts/core/interfaces/ICoreExtensionRegistry.sol/ICoreExtensionRegistry.json';

export const abi = ABI;

export default buildModule("CoreExtRegistryModule", (m) => {

        const xrdna = new XRDNASigners();
        const config = xrdna.deployment[network.config.chainId || 55555];
        const acct = config.coreExtensionRegistryAdmin;
        const others = config.registrarRegistryOtherAdmins;
        const args = {
            owner: acct,
            otherAdmins: others
        }
        const libs = m.useModule(LibrariesModule);
        const coreReg = m.contract("CoreExtensionRegistry", [args], {
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
            coreExtensionRegistry: coreReg
        }
});