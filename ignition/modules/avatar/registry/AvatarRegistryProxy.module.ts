import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import AvatarRegistryModule from "./AvatarRegistry.module";
import { XRDNASigners } from "../../../../src";
import { network } from "hardhat";

export default buildModule("AvatarRegistryProxyModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const impl = m.useModule(AvatarRegistryModule).avatarRegistry;

        const xrdna = new XRDNASigners();
        const config = xrdna.deployment[network.config.chainId || 55555];
        const owner = config.avatarRegistryAdmin;
        const others = config.avatarRegistryOtherAdmins;

        //this registrar is cloned so any admin props will be replaced once cloned and initialized with new 
        //registrar props
        const args = {
            owner,
            admins: others,
            impl
        }
        
        const rr = m.contract("AvatarRegistryProxy", [args], {
            libraries: {
                LibAccess: libs.LibAccess
            },
            after: [
                impl,
                libs.LibAccess
            ]
        });
        return {
            avatarRegistryProxy: rr
        }
});