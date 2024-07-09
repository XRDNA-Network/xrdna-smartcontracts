import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import CompanyRegistryProxyModule from "../../company/registry/CompanyRegistryProxy.module";
import ExpRegistryProxyModule from "../../experience/registry/ExperienceRegistryProxy.module";
import ExpRegistryModule from "../../experience/registry/ExperienceRegistry.module";
import PortalRegistryProxyModule from "../../portal/PortalRegistryProxy.module";

export default buildModule("ExperienceModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const cRegProxy = m.useModule(CompanyRegistryProxyModule).companyRegistryProxy;
        const expRegProxy = m.useModule(ExpRegistryProxyModule).experienceRegistryProxy;
        const expReg = m.useModule(ExpRegistryModule).experienceRegistry;
        const portalRegProxy = m.useModule(PortalRegistryProxyModule).portalRegistryProxy;


        //this registrar is cloned so any admin props will be replaced once cloned and initialized with new 
        //registrar props
        const args = {
            experienceRegistry: expRegProxy,
            companyRegistry: cRegProxy,
            portalRegistry: portalRegProxy,
        }
        
        const rr = m.contract("Experience", [args], {
            libraries: {
                LibAccess: libs.LibAccess,
            },
            after: [
                cRegProxy,
                expRegProxy,
                cRegProxy,
                portalRegProxy,
                libs.LibAccess

            ]
        });
        const data = m.encodeFunctionCall(expReg, "setEntityImplementation", [rr]);
        m.send("setEntityImplementation", expRegProxy, 0n, data);
        return {
            experience: rr
        }
});