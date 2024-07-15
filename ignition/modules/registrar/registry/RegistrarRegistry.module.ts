import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import { XRDNASigners } from "../../../../src";
import { network } from "hardhat";
import { Future } from "@nomicfoundation/ignition-core";

export default buildModule("RegistrarRegistryModule", (m) => {

        const libs = m.useModule(LibrariesModule);

       
        const rr = m.contract("RegistrarRegistry", [], {
            libraries: {
                LibAccess: libs.LibAccess,
                LibFactory: libs.LibFactory,
                LibRegistration: libs.LibRegistration,
                LibEntityRemoval: libs.LibEntityRemoval
            },
            after: [
                libs.LibEntityRemoval,
                libs.LibFactory,
                libs.LibRegistration,
                libs.LibAccess
            ]
        });
        return {
            registrarRegistry: rr
        }
});