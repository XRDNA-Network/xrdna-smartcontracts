import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import WorldRegistryProxyModule from "../../world/registry/WorldRegistryProxy.module";

export default buildModule("CompanyRegistryModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const worldRegProxy = m.useModule(WorldRegistryProxyModule).worldRegistryProxy;
        

        //this registrar is cloned so any admin props will be replaced once cloned and initialized with new 
        //registrar props
        const args = {
            worldRegistry: worldRegProxy,
        }
        
        const rr = m.contract("CompanyRegistry", [args], {
            libraries: {
                LibEntityRemoval: libs.LibEntityRemoval,
                LibFactory: libs.LibFactory,
                LibRegistration: libs.LibRegistration,
                LibAccess: libs.LibAccess
            },
            after: [
                worldRegProxy,
                libs.LibEntityRemoval,
                libs.LibFactory,
                libs.LibRegistration,
                libs.LibVectorAddress,
                libs.LibAccess
            ]
        });
        return {
            companyRegistry: rr
        }
});