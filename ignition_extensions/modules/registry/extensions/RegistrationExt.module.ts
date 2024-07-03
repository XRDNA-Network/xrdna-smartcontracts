import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { XRDNASigners } from "../../../../src";
import {ethers, network} from 'hardhat';
import LibrariesModule from "../../libraries/Libraries.module";
import CoreExtRegistryModule from "../../core/CoreExtRegistry.module";
import {abi as ABI} from '../../../../artifacts/contracts/core/extensions/signers/interfaces/ISignersExtension.sol/ISignersExtension.json';

export const abi = ABI;
export const name = "xr.registration.RegistrationExt";

export default buildModule("RegistrationExtModule", (m) => {

        
        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).coreExtensionRegistry;
        
        const reg = m.contract("RegistrationExt", [], {
            libraries: {
                LibAccess: libs.LibAccess,
                LibExtensions: libs.LibExtensions,
            },
            after: [
                coreReg,
                libs.LibExtensions,
                libs.LibRegistration
            ]
        });
        
        return {
            registrationExtension: reg
        }
});