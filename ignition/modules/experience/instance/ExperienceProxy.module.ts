import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import ExperienceRegistryProxyModule from "../registry/ExperienceRegistryProxy.module";
import ExperienceRegistryModule from "../registry/ExperienceRegistry.module";
import ExperienceModule from "./Experience.module";

export default buildModule("ExperienceProxyModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const proxy = m.useModule(ExperienceRegistryProxyModule).experienceRegistryProxy;
        const reg = m.useModule(ExperienceRegistryModule).experienceRegistry;
        const exp = m.useModule(ExperienceModule).experience;
        
        const rr = m.contract("ExperienceProxy", [proxy], {
            after: [
                proxy,
                exp,
                libs.LibAccess
            ]
        });
        const data = m.encodeFunctionCall(reg, "setProxyImplementation", [rr]);
        m.send("setProxyImplementation", proxy, 0n, data);
        return {
            experienceProxy: rr
        }
});