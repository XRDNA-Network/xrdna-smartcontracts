import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../libraries/Libraries.module";
import CoreExtRegistryModule from "../CoreExtRegistry.module";
import {abi as ABI} from '../../../../artifacts/contracts/core/extensions/signers/interfaces/ISignersExtension.sol/ISignersExtension.json';

export const abi = ABI;
export const name = "xr.core.SignersExt";

export default buildModule("SignersExtModule", (m) => {

        
        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).coreExtensionRegistry;
        
        const signers = m.contract("SignersExtension", [], {
            libraries: {
                LibAccess: libs.LibAccess,
                LibExtensions: libs.LibExtensions
            },
            after: [
                coreReg
            ]
        });
        
        return {
            signersExtension: signers
        }
});