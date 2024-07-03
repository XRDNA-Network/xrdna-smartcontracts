import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import CoreExtRegistryModule from "../../ext-registry/ExtensionRegistry.module";
import { XRDNASigners } from "../../../../src";
import { network } from "hardhat";
import Extensions from "../../extensions/Extensions.module";
import { Future } from "@nomicfoundation/ignition-core";
import RegistrarRegistryModule from "../../registrar/registry/RegistrarRegistry.module";

export default buildModule("WorldRegistryModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).extensionsRegistry;
        const regReg = m.useModule(RegistrarRegistryModule).registrarRegistry;
        

        const xrdna = new XRDNASigners();
        const config = xrdna.deployment[network.config.chainId || 55555];
        const owner = config.worldRegistryAdmin;
        const others = config.worldRegistryOtherAdmins;

       const extOut = Extensions;

       m.useModule(extOut);
       const allExts: Future[] = [];
       extOut.futures.forEach((f) => {
           allExts.push(f);
       });

        //this registrar is cloned so any admin props will be replaced once cloned and initialized with new 
        //registrar props
        const args = {
            owner,
            extensionsRegistry: coreReg,
            registrarRegistry: regReg,
            admins: others,
            vectorAuthority: config.vectorAddressAuthority
        }
        
        const rr = m.contract("WorldRegistry", [args], {
            libraries: {
                LibExtensions: libs.LibExtensions,
                LibAccess: libs.LibAccess
            },
            after: [
                coreReg,
                regReg,
                ...allExts,
                libs.LibExtensions,
                libs.LibAccess
            ]
        });
        return {
            worldRegistry: rr
        }
});