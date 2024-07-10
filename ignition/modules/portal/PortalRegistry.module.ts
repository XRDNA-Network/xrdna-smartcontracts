import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../Libraries.module";
import AvatarRegistryModule from "../avatar/registry/AvatarRegistryProxy.module";
import ExperienceRegistryProxyModule from "../experience/registry/ExperienceRegistryProxy.module";
import exp from "constants";

export default buildModule("PortalRegistryModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const avRegProxy = m.useModule(AvatarRegistryModule).avatarRegistryProxy;
        const expRegProxy = m.useModule(ExperienceRegistryProxyModule).experienceRegistryProxy;

        
        //this registrar is cloned so any admin props will be replaced once cloned and initialized with new 
        //registrar props
        const args = {
            avatarRegistry: avRegProxy,
            experienceRegistry: expRegProxy
        }
        
        const rr = m.contract("PortalRegistry", [args], {
            libraries: {
                LibVectorAddress: libs.LibVectorAddress,
                LibAccess: libs.LibAccess
            },
            after: [
                avRegProxy,
                libs.LibVectorAddress,
                libs.LibAccess
            ]
        });
        return {
            portalRegistry: rr
        }
});