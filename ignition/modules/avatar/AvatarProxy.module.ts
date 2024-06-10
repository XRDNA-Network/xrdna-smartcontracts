import { buildModule } from "@nomicfoundation/ignition-core";
import AvatarFactoryModule from "./AvatarFactory.module";
import AvatarRegistryModule from "./AvatarRegistry.module";

export default buildModule("AvatarProxy", (m) => {
    
    const reg = m.useModule(AvatarRegistryModule);
    const fac = m.useModule(AvatarFactoryModule);

    const args = {
        factory: fac.avatarFactory,
        registry: reg.avatarRegistry
    }
    const master = m.contract("AvatarProxy", [args], {
        after: [fac.avatarFactory, 
                reg.avatarRegistry
            ]
    });
    m.call(fac.avatarFactory, "setProxyImplementation", [master]);
    return {
        avatarProxyMasterCopy: master,
        avatarRegistry: reg.avatarRegistry,
        avatarFactory: fac.avatarFactory,
    }
});