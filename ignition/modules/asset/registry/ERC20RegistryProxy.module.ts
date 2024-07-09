import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import ERC20RegistryModule from "./ERC20Registry.module";
import { XRDNASigners } from "../../../../src";
import { network } from "hardhat";

export default buildModule("ERC20RegistryProxyModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const erc20Registry = m.useModule(ERC20RegistryModule).erc20Registry;

        const xrdna = new XRDNASigners();
        const config = xrdna.deployment[network.config.chainId || 55555];
        const owner = config.assetRegistryAdmin;
        const others = config.assetRegistryOtherAdmins;

        //this registrar is cloned so any admin props will be replaced once cloned and initialized with new 
        //registrar props
        const args = {
            owner,
            admins: others,
            impl: erc20Registry
        }
        
        const rr = m.contract("ERC20RegistryProxy", [args], {
            libraries: {
                LibAccess: libs.LibAccess
            },
            after: [
                erc20Registry,
                libs.LibAccess
            ]
        });
        return {
            erc20RegistryProxy: rr
        }
});