import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../../Libraries.module";
import CoreExtRegistryModule from "../../../ext-registry/ExtensionRegistry.module";


export default buildModule("CompanyRemovalExtModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).extensionsRegistry;
        
        const rre = m.contract("CompanyRemovalExt", [], {
            libraries: {
                LibExtensions: libs.LibExtensions,
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
            companyRemovalExtension: rre
        }
});