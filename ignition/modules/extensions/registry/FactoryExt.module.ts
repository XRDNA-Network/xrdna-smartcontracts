import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import CoreExtRegistryModule from "../../ext-registry/ExtensionRegistry.module";

export default buildModule("FactoryExtModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).extensionsRegistry;
        
        const fe = m.contract("FactoryExt", [], {
            libraries: {
                LibExtensions: libs.LibExtensions,
                LibFactory: libs.LibFactory
            },
            after: [
                coreReg,
                libs.LibExtensions,
                libs.LibFactory
            ]
        });
        //m.call(coreReg, "addExtension", [fe])
        return {
            factoryExtension: fe
        }
});