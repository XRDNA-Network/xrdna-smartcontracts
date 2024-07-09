import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../../Libraries.module";
import CoreExtRegistryModule from "../../../ext-registry/ExtensionRegistry.module";

export default buildModule("ChangeWorldRegistrarExtModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).extensionsRegistry;

        
        const cwr = m.contract("ChangeWorldRegistrarExt", [], {
            libraries: {
                LibControlChange: libs.LibControlChange
            },
            after: [

                coreReg,
                libs.LibControlChange
            ]
        });
        //m.call(coreReg, "addExtension", [cwr])
        return {
            changeWorldRegistrarExtention: cwr
        }
});