import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import RegistrarRegistryModule from "../../registrar/registry/RegistrarRegistry.module";
import FactoryExtModule from "../../extensions/registry/FactoryExt.module";
import CompanyRegistryModule from "../../company/registry/CompanyRegistry.module";
import CompanyExtResolverModule from "./CompanyExtResolver.module";
import WorldRegistryModule from "../../world/registry/WorldRegistry.module";
import ERC20RegistryModule from "../../asset/registry/ERC20Registry.module";
import ERC721RegistryModule from "../../asset/registry/ERC721Registry.module";
import AvatarRegistryModule from "../../avatar/registry/AvatarRegistry.module";

export default buildModule("CompanyModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const cExtResolver = m.useModule(CompanyExtResolverModule).companyExtensionResolver;
        const worldReg = m.useModule(WorldRegistryModule).worldRegistry;
        const cReg = m.useModule(CompanyRegistryModule).companyRegistry;
        const regReg = m.useModule(RegistrarRegistryModule).registrarRegistry;
        const factoryExt = m.useModule(FactoryExtModule).factoryExtension;
        const erc20Reg = m.useModule(ERC20RegistryModule).erc20Registry;
        const erc721Reg = m.useModule(ERC721RegistryModule).erc721Registry;
        const avatarReg = m.useModule(AvatarRegistryModule).avatarRegistry;


        //this registrar is cloned so any admin props will be replaced once cloned and initialized with new 
        //registrar props
        const args = {
            extensionResolver: cExtResolver,
            owningRegistry: cReg,
            worldRegistry: worldReg,
            erc20Registry: erc20Reg,
            erc721Registry: erc721Reg,
            avatarRegistry: avatarReg,
        }
        
        const rr = m.contract("Company", [args], {
            libraries: {
                LibAccess: libs.LibAccess,
                LibVectorAddress: libs.LibVectorAddress
            },
            after: [
                cExtResolver,
                worldReg,
                regReg,
                cReg,
                erc20Reg,
                erc721Reg,
                avatarReg,
                libs.LibAccess

            ]
        });
        const data = m.encodeFunctionCall(factoryExt, "setEntityImplementation", [rr]);
        m.send("setEntityImplementation", cReg, 0n, data);
        return {
            company: rr
        }
});