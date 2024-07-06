import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../Libraries.module";
import CoreExtRegistryModule from "../ext-registry/ExtensionRegistry.module";

export default buildModule("AccessExtModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).extensionsRegistry;
        
        const ae = m.contract("AccessExt", [], {
            libraries: {
                LibAccess: libs.LibAccess
            },
            after: [
                coreReg,
                libs.LibAccess
            ]
        });
       // m.call(coreReg, "addExtension", [ae])
        return {
            accessExtension: ae
        }
});