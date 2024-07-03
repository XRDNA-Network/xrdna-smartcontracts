import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../../Libraries.module";
import CoreExtRegistryModule from "../../../ext-registry/ExtensionRegistry.module";


export default buildModule("CompanyRegistrationExtModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).extensionsRegistry;
        
        const rre = m.contract("CompanyRegistrationExt", [], {
            libraries: {
                LibExtensions: libs.LibExtensions,
                LibRegistration: libs.LibRegistration,
            },
            after: [
                coreReg,
                libs.LibExtensions,
                libs.LibRegistration,
                libs.LibAccess
            ]
        });
        return {
            companyRegistrationExtension: rre
        }
});