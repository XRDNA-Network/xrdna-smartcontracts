import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import RegistrarRegistryModule from "./RegistrarRegistry.module";
import { XRDNASigners } from "../../../../src";
import { network } from "hardhat";

export default buildModule("RegistrarRegistryProxyModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const impl = m.useModule(RegistrarRegistryModule).registrarRegistry;

        const xrdna = new XRDNASigners();
        const config = xrdna.deployment[network.config.chainId || 55555];
        const owner = config.registrarRegistryAdmin;
        const others = config.registrarRegistryOtherAdmins;

        //this registrar is cloned so any admin props will be replaced once cloned and initialized with new 
        //registrar props
        const args = {
            owner,
            admins: others,
            impl
        }
        
        const rr = m.contract("RegistrarRegistryProxy", [args], {
            libraries: {
                LibAccess: libs.LibAccess
            },
            after: [
                impl,
                libs.LibAccess
            ]
        });
        return {
            registrarRegistryProxy: rr
        }
});