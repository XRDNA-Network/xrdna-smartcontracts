import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../../Libraries.module";
import FactoryExtModule from "../../../extensions/registry/FactoryExt.module";
import CompanyRegistryModule from "../../../company/registry/CompanyRegistry.module";
import AvatarRegistryModule from "../../../avatar/registry/AvatarRegistry.module";
import ERC20RegistryModule from '../../registry/ERC20Registry.module';
import ERC20ExtResolverModule from './NTERC20ExtResolver.module';


export default buildModule("NTERC20AssetModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const extResolver = m.useModule(ERC20ExtResolverModule).erc20ExtensionResolver;
        const aReg = m.useModule(AvatarRegistryModule).avatarRegistry;
        const compReg = m.useModule(CompanyRegistryModule).companyRegistry;
        const erc20Reg = m.useModule(ERC20RegistryModule).erc20Registry;
        const factoryExt = m.useModule(FactoryExtModule).factoryExtension;


        //this registrar is cloned so any admin props will be replaced once cloned and initialized with new 
        //registrar props
        const args = {
            extensionResolver: extResolver,
            assetRegistry: erc20Reg,
            companyRegistry: compReg,
            avatarRegistry: aReg,
        }
        
        const rr = m.contract("NTERC20Asset", [args], {
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
        m.send("setEntityImplementation", erc20Reg, 0n, data);
        return {
            erc20Asset: rr,
            erc20Registry: erc20Reg,
            erc20ExtensionResolver: extResolver
        }
});