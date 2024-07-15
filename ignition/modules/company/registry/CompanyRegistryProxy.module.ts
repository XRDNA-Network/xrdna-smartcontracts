import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import CompanyRegistryModule from "./CompanyRegistry.module";
import { XRDNASigners } from "../../../../src";
import { network } from "hardhat";

export default buildModule("CompanyRegistryProxyModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const impl = m.useModule(CompanyRegistryModule).companyRegistry;

        const xrdna = new XRDNASigners();
        const config = xrdna.deployment[network.config.chainId || 55555];
        const owner = config.companyRegistryAdmin;
        const others = config.companyRegistryOtherAdmins;

        //this registrar is cloned so any admin props will be replaced once cloned and initialized with new 
        //registrar props
        const args = {
            owner,
            admins: others,
            impl
        }
        
        const rr = m.contract("CompanyRegistryProxy", [args], {
            libraries: {
                LibAccess: libs.LibAccess
            },
            after: [
                impl,
                libs.LibAccess
            ]
        });
        return {
            companyRegistryProxy: rr
        }
});