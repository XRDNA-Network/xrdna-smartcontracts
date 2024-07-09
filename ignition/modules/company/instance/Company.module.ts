import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import RegistrarRegistryProxyModule from "../../registrar/registry/RegistrarRegistryProxy.module";
import CompanyRegistryProxyModule from "../../company/registry/CompanyRegistryProxy.module";
import CompanyRegistryModule from "../../company/registry/CompanyRegistry.module";
import ExperienceRegistryProxyModule from '../../experience/registry/ExperienceRegistryProxy.module';
import ERC20RegistryProxyModule from "../../asset/registry/ERC20RegistryProxy.module";
import ERC721RegistryProxyModule from "../../asset/registry/ERC721RegistryProxy.module";
import AvatarRegistryProxyModule from "../../avatar/registry/AvatarRegistryProxy.module";

export default buildModule("CompanyModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const cRegProxy = m.useModule(CompanyRegistryProxyModule).companyRegistryProxy;
        const cReg = m.useModule(CompanyRegistryModule).companyRegistry;
        const expRegProxy = m.useModule(ExperienceRegistryProxyModule).experienceRegistryProxy;
        const regRegProxy = m.useModule(RegistrarRegistryProxyModule).registrarRegistryProxy;
        const erc20RegProxy = m.useModule(ERC20RegistryProxyModule).erc20RegistryProxy;
        const erc721RegProxy = m.useModule(ERC721RegistryProxyModule).erc721RegistryProxy;
        const avatarRegProxy = m.useModule(AvatarRegistryProxyModule).avatarRegistryProxy;


        //this registrar is cloned so any admin props will be replaced once cloned and initialized with new 
        //registrar props
        const args = {
            companyRegistry: cRegProxy,
            experienceRegistry: expRegProxy,
            erc20Registry: erc20RegProxy,
            erc721Registry: erc721RegProxy,
            avatarRegistry: avatarRegProxy,
        }
        
        const rr = m.contract("Company", [args], {
            libraries: {
                LibAccess: libs.LibAccess
            },
            after: [
                regRegProxy,
                expRegProxy,
                cReg,
                erc20RegProxy,
                erc721RegProxy,
                avatarRegProxy,
                libs.LibAccess

            ]
        });
        const data = m.encodeFunctionCall(cReg, "setEntityImplementation", [rr]);
        m.send("setCompanyEntityImplementation", cRegProxy, 0n, data);
        return {
            company: rr
        }
});