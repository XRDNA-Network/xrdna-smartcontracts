import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import AvatarRegistryProxyModule from "../registry/AvatarRegistryProxy.module";
import AvatarRegistryModule from "../registry/AvatarRegistry.module";
import AvatarModule from "./Avatar.module";

export default buildModule("AvatarProxyModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const proxy = m.useModule(AvatarRegistryProxyModule).avatarRegistryProxy;
        const reg = m.useModule(AvatarRegistryModule).avatarRegistry;
        const av = m.useModule(AvatarModule).avatar;
        
        const rr = m.contract("AvatarProxy", [proxy], {
           
            after: [
                reg,
                av,
                libs.LibAccess
            ]
        });
        const data = m.encodeFunctionCall(reg, "setProxyImplementation", [rr]);
        m.send("setProxyImplementation", proxy, 0n, data);
        return {
            avataryProxy: rr
        }
});