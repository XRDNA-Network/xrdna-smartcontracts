import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import RegistrarRegistryModule from "../../registrar/registry/RegistrarRegistry.module";
import FactoryExtModule from "../../extensions/registry/FactoryExt.module";
import CompanyRegistryModule from "../../company/registry/CompanyRegistry.module";
import AvatarExtResolverModule from "./AvatarExtResolver.module";
import WorldRegistryModule from "../../world/registry/WorldRegistry.module";
import AvatarRegistryModule from "../registry/AvatarRegistry.module";
import ExperienceRegistryModule from "../../experience/registry/ExperienceRegistry.module";

export default buildModule("AvatarModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const aExtResolver = m.useModule(AvatarExtResolverModule).avatarExtensionResolver;
        const worldReg = m.useModule(WorldRegistryModule).worldRegistry;
        const aReg = m.useModule(AvatarRegistryModule).avatarRegistry;
        const regReg = m.useModule(RegistrarRegistryModule).registrarRegistry;
        const factoryExt = m.useModule(FactoryExtModule).factoryExtension;
        const expRegistry = m.useModule(ExperienceRegistryModule).experienceRegistry;


        //this registrar is cloned so any admin props will be replaced once cloned and initialized with new 
        //registrar props
        const args = {
            extensionResolver: aExtResolver,
            owningRegistry: aReg,
            worldRegistry: worldReg,
            experienceRegistry: expRegistry
        }
        
        const rr = m.contract("Avatar", [args], {
            libraries: {
                LibAccess: libs.LibAccess,
            },
            after: [
                aExtResolver,
                worldReg,
                regReg,
                aReg,
                libs.LibAccess

            ]
        });
        const data = m.encodeFunctionCall(factoryExt, "setEntityImplementation", [rr]);
        m.send("setEntityImplementation", aReg, 0n, data);
        return {
            avatar: rr
        }
});