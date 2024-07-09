import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import { XRDNASigners } from "../../../../src";
import { network } from "hardhat";
import WorldRegistryProxyModule from "../../world/registry/WorldRegistryProxy.module";

export default buildModule("AvatarRegistryModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const worldRegProxy = m.useModule(WorldRegistryProxyModule).worldRegistryProxy;


        //this registrar is cloned so any admin props will be replaced once cloned and initialized with new 
        //registrar props
        const args = {
            worldRegistry: worldRegProxy,
        }
        
        const rr = m.contract("AvatarRegistry", [args], {
            libraries: {
                LibFactory: libs.LibFactory,
                LibRegistration: libs.LibRegistration,
                LibAccess: libs.LibAccess
            },
            after: [
                worldRegProxy,
                libs.LibAccess
            ]
        });
        return {
            avatarRegistry: rr
        }
});