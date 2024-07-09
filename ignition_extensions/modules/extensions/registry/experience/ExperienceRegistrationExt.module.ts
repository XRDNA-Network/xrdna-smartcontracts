import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../../Libraries.module";
import CoreExtRegistryModule from "../../../ext-registry/ExtensionRegistry.module";


export default buildModule("ExperienceRegistrationExtModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).extensionsRegistry;
        
        const rre = m.contract("ExperienceRegistrationExt", [], {
            libraries: {
                LibRegistration: libs.LibRegistration,
                LibVectorAddress: libs.LibVectorAddress
            },
            after: [
                coreReg,
                libs.LibRegistration,
                libs.LibVectorAddress,
                libs.LibAccess
            ]
        });
        return {
            experienceRegistrationExtension: rre
        }
});