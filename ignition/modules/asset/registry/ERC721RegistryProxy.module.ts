import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import ERC721RegistryModule from "./ERC721Registry.module";
import { XRDNASigners } from "../../../../src";
import { network } from "hardhat";

export default buildModule("ERC721RegistryProxyModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const erc721Registry = m.useModule(ERC721RegistryModule).erc721Registry;

        const xrdna = new XRDNASigners();
        const config = xrdna.deployment[network.config.chainId || 55555];
        const owner = config.assetRegistryAdmin;
        const others = config.assetRegistryOtherAdmins;

        //this registrar is cloned so any admin props will be replaced once cloned and initialized with new 
        //registrar props
        const args = {
            owner,
            admins: others,
            impl: erc721Registry
        }
        
        const rr = m.contract("ERC721RegistryProxy", [args], {
            libraries: {
                LibAccess: libs.LibAccess
            },
            after: [
                erc721Registry,
                libs.LibAccess
            ]
        });
        return {
            erc721RegistryProxy: rr
        }
});