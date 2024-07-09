import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import CoreExtRegistryModule from "../../ext-registry/ExtensionRegistry.module";

export default buildModule("FactoryExtModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).extensionsRegistry;
        
        const fe = m.contract("FactoryExt", [], {
            libraries: {
                LibFactory: libs.LibFactory
            },
            after: [
                coreReg,
                libs.LibFactory
            ]
        });
        //m.call(coreReg, "addExtension", [fe])
        return {
            factoryExtension: fe
        }
});