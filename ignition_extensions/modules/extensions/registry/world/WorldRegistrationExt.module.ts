import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../../Libraries.module";
import CoreExtRegistryModule from "../../../ext-registry/ExtensionRegistry.module";
import RegistrarRegistryModule from "../../../registrar/registry/RegistrarRegistry.module";

export default buildModule("WorldRegistrationExtModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).extensionsRegistry;
        
        const wre = m.contract("WorldRegistrationExt", [], {
            libraries: {
                LibRegistration: libs.LibRegistration,
                LibVectorAddress: libs.LibVectorAddress
            },
            after: [
                coreReg,
                libs.LibRegistration
            ]
        });
       // m.call(coreReg, "addExtension", [wre])
        return {
            worldRegistrationExtension: wre
        }
});