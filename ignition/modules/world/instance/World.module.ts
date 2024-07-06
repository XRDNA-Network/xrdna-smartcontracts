import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import WorldRegistryModule from "../registry/WorldRegistry.module";
import RegistrarRegistryModule from "../../registrar/registry/RegistrarRegistry.module";
import FactoryExtModule from "../../extensions/registry/FactoryExt.module";
import WorldExtResolverModule from "./WorldExtResolver.module";
import CompanyRegistryModule from "../../company/registry/CompanyRegistry.module";
import AvatarRegistryModule from "../../avatar/registry/AvatarRegistry.module";
import ExpRegistryModule from "../../experience/registry/ExperienceRegistry.module";

export default buildModule("WorldModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const wExtResolver = m.useModule(WorldExtResolverModule).worldExtensionResolver;
        const worldReg = m.useModule(WorldRegistryModule).worldRegistry;
        const cReg = m.useModule(CompanyRegistryModule).companyRegistry;
        const regReg = m.useModule(RegistrarRegistryModule).registrarRegistry;
        const factoryExt = m.useModule(FactoryExtModule).factoryExtension;
        const aReg = m.useModule(AvatarRegistryModule).avatarRegistry;
        const expReg = m.useModule(ExpRegistryModule).experienceRegistry;


        //this registrar is cloned so any admin props will be replaced once cloned and initialized with new 
        //registrar props
        const args = {
            extensionResolver: wExtResolver,
            owningRegistry: worldReg,
            registrarRegistry: regReg,
            companyRegistry: cReg,
            avatarRegistry: aReg,
            experienceRegistry: expReg
        }
        
        const rr = m.contract("World", [args], {
            libraries: {
                LibAccess: libs.LibAccess,
                LibVectorAddress: libs.LibVectorAddress
            },
            after: [
                wExtResolver,
                worldReg,
                regReg,
                cReg,
                aReg,
                expReg,
                libs.LibAccess

            ]
        });
        const data = m.encodeFunctionCall(factoryExt, "setEntityImplementation", [rr]);
        m.send("setEntityImplementation", worldReg, 0n, data);
        return {
            world: rr
        }
});