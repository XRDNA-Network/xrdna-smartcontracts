import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import WorldRegistryProxyModule from "../registry/WorldRegistryProxy.module";
import WorldRegistryModule from "../registry/WorldRegistry.module";
import RegistrarRegistryProxyModule from "../../registrar/registry/RegistrarRegistryProxy.module";
import CompanyRegistryProxyModule from "../../company/registry/CompanyRegistryProxy.module";
import AvatarRegistryProxyModule from "../../avatar/registry/AvatarRegistryProxy.module";
import ExpRegistryProxyModule from "../../experience/registry/ExperienceRegistryProxy.module";

export default buildModule("WorldModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const worldRegProxy = m.useModule(WorldRegistryProxyModule).worldRegistryProxy;
        const worldReg = m.useModule(WorldRegistryModule).worldRegistry;
        const cRegProxy = m.useModule(CompanyRegistryProxyModule).companyRegistryProxy;
        const regRegProxy = m.useModule(RegistrarRegistryProxyModule).registrarRegistryProxy;
        const aRegProxy = m.useModule(AvatarRegistryProxyModule).avatarRegistryProxy;
        const expRegProxy = m.useModule(ExpRegistryProxyModule).experienceRegistryProxy;


        //this registrar is cloned so any admin props will be replaced once cloned and initialized with new 
        //registrar props
        const args = {
            worldRegistry: worldRegProxy,
            registrarRegistry: regRegProxy,
            companyRegistry: cRegProxy,
            avatarRegistry: aRegProxy,
            experienceRegistry: expRegProxy
        }
        
        const rr = m.contract("World", [args], {
            libraries: {
                LibAccess: libs.LibAccess
            },
            after: [
                worldRegProxy,
                regRegProxy,
                cRegProxy,
                aRegProxy,
                expRegProxy,
                libs.LibAccess

            ]
        });
        const data = m.encodeFunctionCall(worldReg, "setEntityImplementation", [rr]);
        m.send("setEntityImplementation", worldRegProxy, 0n, data);
        return {
            world: rr
        }
});