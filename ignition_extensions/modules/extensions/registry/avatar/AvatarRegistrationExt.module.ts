import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../../Libraries.module";
import CoreExtRegistryModule from "../../../ext-registry/ExtensionRegistry.module";


export default buildModule("AvatarRegistrationExtModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).extensionsRegistry;
        
        const rre = m.contract("AvatarRegistrationExt", [], {
            libraries: {
                LibRegistration: libs.LibRegistration,
            },
            after: [
                coreReg,
                libs.LibRegistration,
                libs.LibAccess
            ]
        });
        return {
            avatarRegistrationExtension: rre
        }
});