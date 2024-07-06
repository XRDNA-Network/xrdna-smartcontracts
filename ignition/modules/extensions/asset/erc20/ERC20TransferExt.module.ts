import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../../Libraries.module";
import CoreExtRegistryModule from "../../../ext-registry/ExtensionRegistry.module";

export default buildModule("ERC20TransferExtModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).extensionsRegistry;
        
        const ei = m.contract("ERC20TransferExt", [], {
            
            after: [
                coreReg
            ]
        });
        return {
            ERC20TransferExtension: ei
        }
});