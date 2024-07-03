import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import CoreExtRegistryModule from "../../ext-registry/ExtensionRegistry.module";
import { XRDNASigners } from "../../../../src";
import { network } from "hardhat";
import Extensions from "../../extensions/Extensions.module";
import { Future } from "@nomicfoundation/ignition-core";

export default buildModule("WorldExtResolverModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).extensionsRegistry;
        const extOut = Extensions;

        m.useModule(extOut);
        const allExts: Future[] = [];
        extOut.futures.forEach((f) => {
            allExts.push(f);
        });

        const xrdna = new XRDNASigners();
        const config = xrdna.deployment[network.config.chainId || 55555];
        const owner = config.worldExtResolverAdmin;
        const others = config.worldExtResolverOtherAdmins;

        const args = {
            owner,
            extensionsRegistry: coreReg,
            admins: others
        }
        
        const re = m.contract("WorldExtResolver", [args], {
            libraries: {
                LibExtensions: libs.LibExtensions,
                LibAccess: libs.LibAccess
            },
            after: [
                coreReg,
                ...allExts,
                libs.LibExtensions,
                libs.LibAccess
            ]
        });
        return {
            worldExtensionResolver: re
        }
});