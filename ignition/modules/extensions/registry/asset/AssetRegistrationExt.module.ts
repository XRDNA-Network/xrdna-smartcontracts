import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../../Libraries.module";
import CoreExtRegistryModule from "../../../ext-registry/ExtensionRegistry.module";


export default buildModule("AssetRegistrationExtModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).extensionsRegistry;
        
        const rre = m.contract("AssetRegistrationExt", [], {
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
        return {
            assetRegistrationExtension: rre
        }
});