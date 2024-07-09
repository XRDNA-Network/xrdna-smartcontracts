import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../../Libraries.module";
import CoreExtRegistryModule from "../../../ext-registry/ExtensionRegistry.module";

export default buildModule("ERC20InfoExtModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).extensionsRegistry;
        
        const ei = m.contract("ERC20InfoExt", [], {
            
            after: [
                coreReg
            ]
        });
        return {
            ERC20InfoExtension: ei
        }
});