import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../../Libraries.module";
import CoreExtRegistryModule from "../../../ext-registry/ExtensionRegistry.module";


export default buildModule("RegistrarRegistrationExtModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).extensionsRegistry;
        
        const rre = m.contract("RegistrarRegistrationExt", [], {
            libraries: {
                LibRegistration: libs.LibRegistration,
                LibAccess: libs.LibAccess
            },
            after: [
                coreReg,
                libs.LibRegistration,
                libs.LibAccess
            ]
        });
       // m.call(coreReg, "addExtension", [rre])
        return {
            registrarRegistrationExtension: rre
        }
});