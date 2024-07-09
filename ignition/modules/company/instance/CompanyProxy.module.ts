import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import CompanyRegistryProxyModule from "../registry/CompanyRegistryProxy.module";
import CompanyRegistryModule from "../registry/CompanyRegistry.module";
import CompanyModule from "./Company.module";

export default buildModule("CompanyProxyModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const proxy = m.useModule(CompanyRegistryProxyModule).companyRegistryProxy;
        const reg = m.useModule(CompanyRegistryModule).companyRegistry;
        const comp = m.useModule(CompanyModule).company;
        
        const rr = m.contract("CompanyProxy", [proxy], {
            after: [
                proxy,
                comp,
                libs.LibAccess
            ]
        });
        const data = m.encodeFunctionCall(reg, "setProxyImplementation", [rr]);
        m.send("setProxyImplementation", proxy, 0n, data);
        return {
            companyProxy: rr
        }
});