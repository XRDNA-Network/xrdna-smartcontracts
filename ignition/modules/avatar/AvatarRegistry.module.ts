import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {config} from "../config";
import AvatarFactoryModule from "./AvatarFactory.module";
import WorldRegistryModule0_2 from "../world/WorldRegistry.module";

export default buildModule("AvatarRegistry", (m) => {
    
    const admins = config.avatarRegistryAdmins;

    const fac = m.useModule(AvatarFactoryModule);
    const wReg = m.useModule(WorldRegistryModule0_2);
    const acct = m.getAccount(0);
    const args = {
        mainAdmin: acct,
        admins,
        avatarFactory: fac.avatarFactory,
        worldRegistry: wReg.worldRegistry
    }
    const Registry = m.contract("AvatarRegistry", [args], {
        after: [fac.avatarFactory, wReg.worldRegistry]
    });
    m.call(fac.avatarFactory, "setAuthorizedRegistry", [Registry]);
    return {avatarRegistry: Registry};
});