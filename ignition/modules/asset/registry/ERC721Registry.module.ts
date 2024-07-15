import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import { XRDNASigners } from "../../../../src";
import { network } from "hardhat";

export default buildModule("ERC721RegistryModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        
        const rr = m.contract("ERC721Registry", [], {
            libraries: {
                LibFactory: libs.LibFactory,
                LibRegistration: libs.LibRegistration,
                LibEntityRemoval: libs.LibEntityRemoval,
                LibAccess: libs.LibAccess
            },
            after: [
                libs.LibEntityRemoval,
                libs.LibFactory,
                libs.LibRegistration,
                libs.LibAccess
            ]
        });
        return {
            erc721Registry: rr
        }
});