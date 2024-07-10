import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import WorldRegistryModule from "../../world/registry/WorldRegistryProxy.module";
import CompanyRegistryModule from "../../company/registry/CompanyRegistryProxy.module";
import AvatarRegistryProxyModule from "../../avatar/registry/AvatarRegistryProxy.module";
import AvatarRegistryModule from "../../avatar/registry/AvatarRegistry.module";


export default buildModule("ExperienceRegistryModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const worldRegProxy = m.useModule(WorldRegistryModule).worldRegistryProxy;
        
        const avatarRegProxy = m.useModule(AvatarRegistryProxyModule).avatarRegistryProxy;
        const companyRegProxy = m.useModule(CompanyRegistryModule).companyRegistryProxy;

        //this registrar is cloned so any admin props will be replaced once cloned and initialized with new 
        //registrar props
        const args = {
            worldRegistry: worldRegProxy,
            companyRegistry: companyRegProxy,
        }
        
        const rr = m.contract("ExperienceRegistry", [args], {
            libraries: {
                LibFactory: libs.LibFactory,
                LibRegistration: libs.LibRegistration,
                LibVectorAddress: libs.LibVectorAddress,
                LibEntityRemoval: libs.LibEntityRemoval,
                LibAccess: libs.LibAccess
            },
            after: [
                worldRegProxy,
                companyRegProxy,
                avatarRegProxy,
                libs.LibEntityRemoval,
                libs.LibFactory,
                libs.LibRegistration,
                libs.LibVectorAddress,
                libs.LibAccess
            ]
        });

        
        
        return {
            experienceRegistry: rr
        }
});