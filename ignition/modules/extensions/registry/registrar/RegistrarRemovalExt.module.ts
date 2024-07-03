import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../../Libraries.module";
import CoreExtRegistryModule from "../../../ext-registry/ExtensionRegistry.module";


export default buildModule("RegistrarRemovalExtModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).extensionsRegistry;
        
        const rre = m.contract("RegistrarRemovalExt", [], {
            libraries: {
                LibExtensions: libs.LibExtensions,
                LibAccess: libs.LibAccess,
                LibEntityRemoval: libs.LibEntityRemoval
            },
            after: [
                coreReg,
                libs.LibExtensions,
                libs.LibEntityRemoval,
                libs.LibAccess
            ]
        });
       // m.call(coreReg, "addExtension", [rre])
        return {
            registrarRemovalExtension: rre
        }
});