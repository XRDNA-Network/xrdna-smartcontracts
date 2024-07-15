import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../Libraries.module";
import PortalRegistryModule from "./PortalRegistry.module";
import { XRDNASigners } from "../../../src";
import { network } from "hardhat";

export default buildModule("PortalRegistryProxyModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const impl = m.useModule(PortalRegistryModule).portalRegistry;

        const xrdna = new XRDNASigners();
        const config = xrdna.deployment[network.config.chainId || 55555];
        const owner = config.portalRegistryAdmin;
        const others = config.portalRegistryOtherAdmins;

        //this registrar is cloned so any admin props will be replaced once cloned and initialized with new 
        //registrar props
        const args = {
            owner,
            admins: others,
            impl
        }
        
        const rr = m.contract("PortalRegistryProxy", [args], {
            libraries: {
                LibAccess: libs.LibAccess
            },
            after: [
                impl,
                libs.LibAccess
            ]
        });
        return {
            portalRegistryProxy: rr
        }
});