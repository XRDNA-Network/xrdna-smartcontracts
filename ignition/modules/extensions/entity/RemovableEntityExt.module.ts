import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import CoreExtRegistryModule from "../../ext-registry/ExtensionRegistry.module";

export default buildModule("RemovableEntityExtModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).extensionsRegistry;
        
        const re = m.contract("RemovableEntityExt", [], {
            libraries: {
                LibExtensions: libs.LibExtensions,
            },
            after: [
                coreReg,
                libs.LibExtensions,
            ]
        });
       // m.call(coreReg, "addExtension", [re])
        return {
            removableEntityExtension: re
        }
});