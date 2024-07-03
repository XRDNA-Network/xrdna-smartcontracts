import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { XRDNASigners } from "../../../src";
import {network} from 'hardhat';
import {abi as ABI} from '../../../artifacts/contracts/example/Example.sol/Example.json';
import ModuleRegistryModule from "../ModuleRegistry.module";
import LibrariesModule from "../Libraries.module";
import AccessModuleModule from "../mods/AccessModule.module";

export const abi = ABI;

export default buildModule("ExampleProxyModule", (m) => {

        const coreReg = m.useModule(ModuleRegistryModule).moduleRegistry
        const access = m.useModule(AccessModuleModule).accessControl
        const libs = m.useModule(LibrariesModule);

        const xrdna = new XRDNASigners();
        const config = xrdna.deployment[network.config.chainId || 55555];
        const owner = config.moduleRegistryAdmin;
        const others = config.moduleRegistryOtherAdmins;
        const args = {
            owner,
            admins: others,
            moduleRegistry: coreReg
        }
        const ex = m.contract("ExampleProxy", [args],{
            libraries: {
                LibAccess: libs.LibAccess
            },
            after: [
                coreReg,
                access,
                libs.LibModule,
                libs.LibAccess,
                libs.LibFunds,
            ]
        });
        
        return {
            exampleProxy: ex
        }
});