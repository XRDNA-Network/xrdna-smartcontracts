import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../Libraries.module";
import { XRDNASigners } from "../../../src";
import { network } from "hardhat";
import AvatarRegistryModule from "../avatar/registry/AvatarRegistryProxy.module";

export default buildModule("PortalRegistryModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const avRegProxy = m.useModule(AvatarRegistryModule).avatarRegistryProxy;

        
        //this registrar is cloned so any admin props will be replaced once cloned and initialized with new 
        //registrar props
        const args = {
            avatarRegistry: avRegProxy,
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