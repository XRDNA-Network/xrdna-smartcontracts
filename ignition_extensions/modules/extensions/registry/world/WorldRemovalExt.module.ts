import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../../Libraries.module";
import CoreExtRegistryModule from "../../../ext-registry/ExtensionRegistry.module";
import RegistrarRegistryModule from "../../../registrar/registry/RegistrarRegistry.module";

export default buildModule("WorldRemovalExtModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).extensionsRegistry;
        
        const wre = m.contract("WorldRemovalExt", [], {
            libraries: {
                LibEntityRemoval: libs.LibEntityRemoval
            },
            after: [
                coreReg,
                libs.LibEntityRemoval
                
            ]
        });
       // m.call(coreReg, "addExtension", [wre])
        return {
            worldRemovalExtension: wre
        }
});