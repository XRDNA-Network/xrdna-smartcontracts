import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../libraries/Libraries.module";
import CoreExtRegistryModule from "../../core/CoreExtRegistry.module";
import {abi as ABI} from '../../../../artifacts/contracts/entity/extensions/removable/interfaces/IRemovableExtension.sol/IRemovableExtension.json';

export const abi = ABI;
export const name = "xr.entity.RemovableExt";

export default buildModule("RemovableExtModule", (m) => {

        
        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).coreExtensionRegistry;
        
        const ee = m.contract("RemovableExt", [], {
            libraries: {
                LibAccess: libs.LibAccess,
                LibExtensions: libs.LibExtensions,
            },
            after: [
                coreReg,
                libs.LibExtensions
            ]
        });
        return {
            removableExtension: ee
        }
});