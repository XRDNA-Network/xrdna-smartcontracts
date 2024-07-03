import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../../Libraries.module";
import CoreExtRegistryModule from "../../../ext-registry/ExtensionRegistry.module";


export default buildModule("ExperienceRegistrationExtModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).extensionsRegistry;
        
        const rre = m.contract("ExperienceRegistrationExt", [], {
            libraries: {
                LibExtensions: libs.LibExtensions,
                LibRegistration: libs.LibRegistration,
                LibVectorAddress: libs.LibVectorAddress
            },
            after: [
                coreReg,
                libs.LibExtensions,
                libs.LibRegistration,
                libs.LibVectorAddress,
                libs.LibAccess
            ]
        });
        return {
            experienceRegistrationExtension: rre
        }
});