import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import CoreExtRegistryModule from "../../ext-registry/ExtensionRegistry.module";
import { XRDNASigners } from "../../../../src";
import { network } from "hardhat";
import Extensions from "../../extensions/Extensions.module";
import { Future } from "@nomicfoundation/ignition-core";
import WorldRegistryModule from "../../world/registry/WorldRegistry.module";

export default buildModule("ExperienceRegistryModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).extensionsRegistry;
        const worldReg = m.useModule(WorldRegistryModule).worldRegistry;
        

        const xrdna = new XRDNASigners();
        const config = xrdna.deployment[network.config.chainId || 55555];
        const owner = config.experienceRegistryAdmin;
        const others = config.experienceRegistryOtherAdmins;

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
            worldRegistry: worldReg,
            admins: others
        }
        
        const rr = m.contract("ExperienceRegistry", [args], {
            libraries: {
                LibExtensions: libs.LibExtensions,
                LibAccess: libs.LibAccess
            },
            after: [
                coreReg,
                worldReg,
                ...allExts,
                libs.LibExtensions,
                libs.LibAccess
            ]
        });
        return {
            experienceRegistry: rr
        }
});