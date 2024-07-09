import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import ExperienceRegistryModule from "./ExperienceRegistry.module";
import { XRDNASigners } from "../../../../src";
import { network } from "hardhat";

import PortalRegistryProxyModule from "../../portal/PortalRegistryProxy.module";
import AvatarRegistryProxyModule from "../../avatar/registry/AvatarRegistryProxy.module";
import PortalRegistryModule from "../../portal/PortalRegistry.module";
import AvatarRegistryModule from "../../avatar/registry/AvatarRegistry.module";

export default buildModule("ExperienceRegistryProxyModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const impl = m.useModule(ExperienceRegistryModule).experienceRegistry;

        const portalRegProxy = m.useModule(PortalRegistryProxyModule).portalRegistryProxy;
        const portalReg = m.useModule(PortalRegistryModule).portalRegistry;
        const avatarRegProxy = m.useModule(AvatarRegistryProxyModule).avatarRegistryProxy;
        const avatarReg = m.useModule(AvatarRegistryModule).avatarRegistry;


        const xrdna = new XRDNASigners();
        const config = xrdna.deployment[network.config.chainId || 55555];
        const owner = config.experienceRegistryAdmin;
        const others = config.experienceRegistryOtherAdmins;

        //this registrar is cloned so any admin props will be replaced once cloned and initialized with new 
        //registrar props
        const args = {
            owner,
            admins: others,
            impl
        }
        
        const rr = m.contract("ExperienceRegistryProxy", [args], {
            libraries: {
                LibAccess: libs.LibAccess
            },
            after: [
                impl,
                portalRegProxy,
                avatarRegProxy,
                libs.LibAccess
            ]
        });

        let data:any = m.encodeFunctionCall(portalReg, "setExperienceRegistry", [rr]);
        m.send("setPortalExperienceRegistry", portalRegProxy, 0n, data);  

        data = m.encodeFunctionCall(avatarReg, "setExperienceRegistry", [rr]);
        m.send("setAvatarExperienceRegistry", avatarRegProxy, 0n, data);

        return {
            experienceRegistryProxy: rr
        }
});