import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";

import RegistrarRegistryModule from "../../registrar/registry/RegistrarRegistry.module";
import RegistrarRegistryProxyModule from "../../registrar/registry/RegistrarRegistryProxy.module";

import AssetRegistryModule from "../../asset/registry/ERC721Registry.module";
import AssetRegistryProxyModule from "../../asset/registry/ERC721RegistryProxy.module";

import AvatarRegistryModule from "../registry/AvatarRegistry.module";
import AvatarRegistryProxyModule from "../registry/AvatarRegistryProxy.module";

import ExperienceRegistryModule from "../../experience/registry/ExperienceRegistry.module";
import ExperienceRegistryProxyModule from "../../experience/registry/ExperienceRegistryProxy.module";

import CompanyRegistryModule from "../../company/registry/CompanyRegistry.module";
import CompanyRegistryProxyModule from "../../company/registry/CompanyRegistryProxy.module";

import PortalRegistryModule from "../../portal/PortalRegistry.module";
import PortalRegistryProxyModule from "../../portal/PortalRegistryProxy.module";

export default buildModule("AvatarModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const aReg = m.useModule(AvatarRegistryModule).avatarRegistry;
        const aRegProxy = m.useModule(AvatarRegistryProxyModule).avatarRegistryProxy;

        const regRegProxy = m.useModule(RegistrarRegistryProxyModule).registrarRegistryProxy;

        const expRegProxy = m.useModule(ExperienceRegistryProxyModule).experienceRegistryProxy;

        const assetRegProxy = m.useModule(AssetRegistryProxyModule).erc721RegistryProxy;

        const portalRegProxy = m.useModule(PortalRegistryProxyModule).portalRegistryProxy;

        const companyRegProxy = m.useModule(CompanyRegistryProxyModule).companyRegistryProxy;

        //this registrar is cloned so any admin props will be replaced once cloned and initialized with new 
        //registrar props
        const args = {
            avatarRegistry: aRegProxy,
            experienceRegistry: expRegProxy,
            erc721Registry: assetRegProxy,
            companyRegistry: companyRegProxy,
            portalRegistry: portalRegProxy,
        }
        
        const rr = m.contract("Avatar", [args], {
            libraries: {
                LibLinkedList: libs.LibLinkedList,
                LibAccess: libs.LibAccess,
            },
            after: [
                regRegProxy,
                aRegProxy,
                assetRegProxy,
                companyRegProxy,
                portalRegProxy,
                libs.LibLinkedList,
                libs.LibAccess

            ]
        });
        const data = m.encodeFunctionCall(aReg, "setEntityImplementation", [rr]);
        m.send("setEntityImplementation", aRegProxy, 0n, data);
        return {
            avatar: rr
        }
});