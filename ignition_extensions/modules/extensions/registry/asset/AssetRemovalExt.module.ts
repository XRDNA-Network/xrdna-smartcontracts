import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../../Libraries.module";
import CoreExtRegistryModule from "../../../ext-registry/ExtensionRegistry.module";


export default buildModule("AssetRemovalExtModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).extensionsRegistry;
        
        const rre = m.contract("AssetRemovalExt", [], {
            libraries: {
                LibEntityRemoval: libs.LibEntityRemoval,
                LibAccess: libs.LibAccess
            },
            after: [
                coreReg,
                libs.LibEntityRemoval,
                libs.LibAccess
            ]
        });
        return {
            assetRemovalExtension: rre
        }
});