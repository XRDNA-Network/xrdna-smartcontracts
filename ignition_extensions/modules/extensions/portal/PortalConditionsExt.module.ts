import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import CoreExtRegistryModule from "../../ext-registry/ExtensionRegistry.module";

export default buildModule("PortalConditionsExtModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).extensionsRegistry;
        
        const pc = m.contract("PortalConditionsExt", [], {
           
            after: [
                coreReg,
            ]
        });
        return {
            portalConditionsExtension: pc
        }
});