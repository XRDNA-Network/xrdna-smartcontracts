import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {XRDNASigners} from '../../../src';
import {network} from 'hardhat';
import AvatarFactoryModule from "./AvatarFactory.module";
import WorldRegistryModule0_2 from "../world/WorldRegistry.module";
import PortalRegistryModule from "../portal/PortalRegistry.module";

export default buildModule("AvatarRegistry", (m) => {
    
    const xrdna = new XRDNASigners();
    const deployConfig = xrdna.deployment[network.config.chainId || 55555];
    const acct = deployConfig.avatarRegistryAdmin;
    const admins = deployConfig.avatarRegistryOtherAdmins;

    const fac = m.useModule(AvatarFactoryModule);
    const wReg = m.useModule(WorldRegistryModule0_2);
    const pReg = m.useModule(PortalRegistryModule);
    const args = {
        mainAdmin: acct,
        admins,
        avatarFactory: fac.avatarFactory,
        worldRegistry: wReg.worldRegistry
    }
    const Registry = m.contract("AvatarRegistry", [args], {
        after: [fac.avatarFactory, wReg.worldRegistry, pReg.portalRegistry]
    });
    m.call(fac.avatarFactory, "setAuthorizedRegistry", [Registry]);
    m.call(pReg.portalRegistry, "setAvatarRegistry", [Registry]);
    return {avatarRegistry: Registry};
});