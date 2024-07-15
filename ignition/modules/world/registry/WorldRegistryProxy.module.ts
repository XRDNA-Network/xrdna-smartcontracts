import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import WorldRegistryModule from "./WorldRegistry.module";
import { XRDNASigners } from "../../../../src";
import { network } from "hardhat";

export default buildModule("WorldRegistryProxyModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const impl = m.useModule(WorldRegistryModule).worldRegistry;


        const xrdna = new XRDNASigners();
        const config = xrdna.deployment[network.config.chainId || 55555];
        const owner = config.worldRegistryAdmin;
        const others = config.worldRegistryOtherAdmins;

        //this registrar is cloned so any admin props will be replaced once cloned and initialized with new 
        //registrar props
        const args = {
            owner,
            admins: others,
            vectorAuthority: config.vectorAddressAuthority,
            impl
        }
        
        const rr = m.contract("WorldRegistryProxy", [args], {
            libraries: {
                LibAccess: libs.LibAccess
            },
            after: [
                impl,
                libs.LibAccess
            ]
        });
        return {
            worldRegistryProxy: rr
        }
});