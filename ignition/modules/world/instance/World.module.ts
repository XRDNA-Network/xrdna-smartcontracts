import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import { XRDNASigners } from "../../../../src";
import { network } from "hardhat";
import WorldRegistryModule from "../registry/WorldRegistry.module";
import Extensions from "../../extensions/Extensions.module";
import { Future } from "@nomicfoundation/ignition-core";
import RegistrarRegistryModule from "../../registrar/registry/RegistrarRegistry.module";
import FactoryExtModule from "../../extensions/registry/FactoryExt.module";
import WorldExtResolverModule from "./WorldExtResolver.module";
import CompanyRegistryModule from "../../company/registry/CompanyRegistry.module";

export default buildModule("WorldModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const wExtResolver = m.useModule(WorldExtResolverModule).worldExtensionResolver;
        const worldReg = m.useModule(WorldRegistryModule).worldRegistry;
        const cReg = m.useModule(CompanyRegistryModule).companyRegistry;
        const regReg = m.useModule(RegistrarRegistryModule).registrarRegistry;
        const factoryExt = m.useModule(FactoryExtModule).factoryExtension;


        //this registrar is cloned so any admin props will be replaced once cloned and initialized with new 
        //registrar props
        const args = {
            extensionResolver: wExtResolver,
            owningRegistry: worldReg,
            registrarRegistry: regReg,
            companyRegistry: cReg
        }
        
        const rr = m.contract("World", [args], {
            libraries: {
                LibExtensions: libs.LibExtensions,
                LibAccess: libs.LibAccess,
                LibVectorAddress: libs.LibVectorAddress
            },
            after: [
                wExtResolver,
                worldReg,
                regReg,
                cReg,
                libs.LibExtensions,
                libs.LibAccess

            ]
        });
        const data = m.encodeFunctionCall(factoryExt, "setEntityImplementation", [rr]);
        m.send("setEntityImplementation", worldReg, 0n, data);
        return {
            world: rr
        }
});