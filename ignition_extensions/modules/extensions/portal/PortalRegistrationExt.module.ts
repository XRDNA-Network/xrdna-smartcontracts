import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import CoreExtRegistryModule from "../../ext-registry/ExtensionRegistry.module";

export default buildModule("PortalRegistrationExtModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).extensionsRegistry;
        
        const rwr = m.contract("PortalRegistrationExt", [], {
            libraries: {
                LibVectorAddress: libs.LibVectorAddress
            },
            after: [
                coreReg,
                libs.LibVectorAddress
            ]
        });
        return {
            portalRegistrationExtension: rwr
        }
});