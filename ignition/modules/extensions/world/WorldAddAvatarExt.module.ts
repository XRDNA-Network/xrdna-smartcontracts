import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import CoreExtRegistryModule from "../../ext-registry/ExtensionRegistry.module";

export default buildModule("WorldAddAvatarExtModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).extensionsRegistry;
        
        const wac = m.contract("WorldAddAvatarExt", [], {
            libraries: {
                LibExtensions: libs.LibExtensions,
                LibAccess: libs.LibAccess,
            },
            after: [
                coreReg,
                libs.LibExtensions,
                libs.LibAccess
            ]
        });
        return {
            worldAddAvatarExtension: wac
        }
});