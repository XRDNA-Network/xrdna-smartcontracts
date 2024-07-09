import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../../Libraries.module";
import FactoryExtModule from "../../../extensions/registry/FactoryExt.module";
import CompanyRegistryModule from "../../../company/registry/CompanyRegistry.module";
import AvatarRegistryModule from "../../../avatar/registry/AvatarRegistry.module";
import ERC721RegistryModule from '../../registry/ERC721Registry.module';
import ERC721ExtResolverModule from './NTERC721ExtResolver.module';


export default buildModule("NTERC721Module", (m) => {

        const libs = m.useModule(LibrariesModule);
        const extResolver = m.useModule(ERC721ExtResolverModule).erc721ExtensionResolver;
        const aReg = m.useModule(AvatarRegistryModule).avatarRegistry;
        const compReg = m.useModule(CompanyRegistryModule).companyRegistry;
        const erc721Reg = m.useModule(ERC721RegistryModule).erc721Registry;
        const factoryExt = m.useModule(FactoryExtModule).factoryExtension;


        //this registrar is cloned so any admin props will be replaced once cloned and initialized with new 
        //registrar props
        const args = {
            extensionResolver: extResolver,
            assetRegistry: erc721Reg,
            companyRegistry: compReg,
            avatarRegistry: aReg,
        }
        
        const rr = m.contract("NTERC721Asset", [args], {
            libraries: {
                LibAccess: libs.LibAccess,
            },
            after: [
                extResolver,
                compReg,
                aReg,
                libs.LibAccess
            ]
        });
        const data = m.encodeFunctionCall(factoryExt, "setEntityImplementation", [rr]);
        m.send("setEntityImplementation", erc721Reg, 0n, data);
        return {
            erc721Asset: rr,
            erc721Registry: erc721Reg,
            erc721ExtensionResolver: extResolver
        }
});