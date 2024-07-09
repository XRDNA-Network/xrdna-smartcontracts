import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../../Libraries.module";
import CompanyRegistryProxyModule from "../../../company/registry/CompanyRegistryProxy.module";
import AvatarRegistryProxyModule from "../../../avatar/registry/AvatarRegistryProxy.module";
import ERC20RegistryProxyModule from '../../registry/ERC20RegistryProxy.module';
import ERC20RegistryModule from '../../registry/ERC20Registry.module';
import ERC20RegistryProxy from '../../registry/ERC20RegistryProxy.module';


export default buildModule("NTERC20AssetModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const aRegProxy = m.useModule(AvatarRegistryProxyModule).avatarRegistryProxy;
        const compRegProxy = m.useModule(CompanyRegistryProxyModule).companyRegistryProxy;
        const erc20Reg = m.useModule(ERC20RegistryModule).erc20Registry;
        const erc20RegProxy = m.useModule(ERC20RegistryProxy).erc20RegistryProxy;

        const args = {
            assetRegistry: erc20RegProxy,
            companyRegistry: compRegProxy,
            avatarRegistry: aRegProxy,
        }
        
        const rr = m.contract("NTERC20Asset", [args], {
            libraries: {
                LibAccess: libs.LibAccess,
            },
            after: [
                compRegProxy,
                aRegProxy,
                erc20RegProxy,
                libs.LibAccess
            ]
        });
        const data = m.encodeFunctionCall(erc20Reg, "setEntityImplementation", [rr]);
        m.send("setEntityImplementation", erc20RegProxy, 0n, data);
        return {
            erc20Asset: rr,
            erc20Registry: erc20RegProxy,
        }
});