import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import { XRDNASigners } from "../../../../src";
import { network } from "hardhat";
import { Future } from "@nomicfoundation/ignition-core";
import RegistrarRegistryProxyModule from "../../registrar/registry/RegistrarRegistryProxy.module";

export default buildModule("WorldRegistryModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const regRegProxy = m.useModule(RegistrarRegistryProxyModule).registrarRegistryProxy;
    

        //this registrar is cloned so any admin props will be replaced once cloned and initialized with new 
        //registrar props
        const args = {
            registrarRegistry: regRegProxy,
        }
        
        const rr = m.contract("WorldRegistry", [args], {
            libraries: {
                LibEntityRemoval: libs.LibEntityRemoval,
                LibFactory: libs.LibFactory,
                LibRegistration: libs.LibRegistration,
                LibVectorAddress: libs.LibVectorAddress,
                LibAccess: libs.LibAccess
            },
            after: [
                regRegProxy,
                libs.LibEntityRemoval,
                libs.LibFactory,
                libs.LibRegistration,
                libs.LibVectorAddress,
                libs.LibAccess
            ]
        });
        return {
            worldRegistry: rr
        }
});