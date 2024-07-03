import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { XRDNASigners } from "../../src";
import {network} from 'hardhat';
import {abi as ABI} from '../../artifacts/contracts/core/IModuleRegistry.sol/IModuleRegistry.json';

export const abi = ABI;

export default buildModule("ModuleRegistryModule", (m) => {

        const xrdna = new XRDNASigners();
        const config = xrdna.deployment[network.config.chainId || 55555];
        const owner = config.moduleRegistryAdmin;
        const others = config.moduleRegistryOtherAdmins;
        const args = {
            owner,
            admins: others
        }
        const coreReg = m.contract("ModuleRegistry", [args]);
        
        return {
            moduleRegistry: coreReg
        }
});