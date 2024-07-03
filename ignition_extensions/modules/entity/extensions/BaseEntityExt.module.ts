import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../libraries/Libraries.module";
import CoreExtRegistryModule from "../../core/CoreExtRegistry.module";
import {abi as ABI} from '../../../../artifacts/contracts/entity/extensions/basic-entity/interfaces/IBasicEntityExt.sol/IBasicEntityExt.json';

export const abi = ABI;
export const name = "xr.entity.BasicEntityExt";

export default buildModule("BasicEntityExtModule", (m) => {

        
        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).coreExtensionRegistry;
        
        const ee = m.contract("BasicEntityExt", [], {
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
            basicEntityExtension: ee
        }
});