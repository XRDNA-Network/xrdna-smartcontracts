import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import CoreExtRegistryModule from "../../ext-registry/ExtensionRegistry.module";

export default buildModule("RegistrarWorldRegExtModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).extensionsRegistry;
        
        const rwr = m.contract("RegistrarWorldRegistrationExt", [], {
            libraries: {
                LibAccess: libs.LibAccess
            },
            after: [
                coreReg,
                libs.LibAccess
            ]
        });
        return {
            registrarWorldRegistrationExtension: rwr
        }
});