


import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../libraries/Libraries.module";
import CoreExtRegistryModule from "../../core/CoreExtRegistry.module";
import {abi as ABI} from '../../../../artifacts/contracts/entity/extensions/terms-owner/interfaces/ITermsOwnerExtension.sol/ITermsOwnerExtension.json';

export const abi = ABI;
export const name = "xr.entity.TermsOwnerExt";

export default buildModule("TermsOwnerExtModule", (m) => {

        
        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).coreExtensionRegistry;
        
        const ee = m.contract("TermsOwnerExt", [], {
            libraries: {
                LibAccess: libs.LibAccess,
                LibExtensions: libs.LibExtensions,
            },
            after: [
                coreReg,
                libs.LibTermsOwner,
            ]
        });
        return {
            termsOwnerExtension: ee
        }
});