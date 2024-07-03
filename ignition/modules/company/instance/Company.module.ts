import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import RegistrarRegistryModule from "../../registrar/registry/RegistrarRegistry.module";
import FactoryExtModule from "../../extensions/registry/FactoryExt.module";
import CompanyRegistryModule from "../../company/registry/CompanyRegistry.module";
import CompanyExtResolverModule from "./CompanyExtResolver.module";
import WorldRegistryModule from "../../world/registry/WorldRegistry.module";

export default buildModule("CompanyModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const cExtResolver = m.useModule(CompanyExtResolverModule).companyExtensionResolver;
        const worldReg = m.useModule(WorldRegistryModule).worldRegistry;
        const cReg = m.useModule(CompanyRegistryModule).companyRegistry;
        const regReg = m.useModule(RegistrarRegistryModule).registrarRegistry;
        const factoryExt = m.useModule(FactoryExtModule).factoryExtension;


        //this registrar is cloned so any admin props will be replaced once cloned and initialized with new 
        //registrar props
        const args = {
            extensionResolver: cExtResolver,
            owningRegistry: cReg,
            worldRegistry: worldReg
        }
        
        const rr = m.contract("Company", [args], {
            libraries: {
                LibExtensions: libs.LibExtensions,
                LibAccess: libs.LibAccess,
                LibVectorAddress: libs.LibVectorAddress
            },
            after: [
                cExtResolver,
                worldReg,
                regReg,
                cReg,
                libs.LibExtensions,
                libs.LibAccess

            ]
        });
        const data = m.encodeFunctionCall(factoryExt, "setEntityImplementation", [rr]);
        m.send("setEntityImplementation", cReg, 0n, data);
        return {
            company: rr
        }
});