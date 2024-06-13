import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {XRDNASigners} from '../../../src';
import {network} from 'hardhat';

export default buildModule("AvatarFactory", (m) => {
    
    const xrdna = new XRDNASigners();
    const deployConfig = xrdna.deployment[network.config.chainId || 55555];
    const acct = deployConfig.avatarFactoryAdmin;
    const admins = deployConfig.avatarFactoryOtherAdmins;
    const Factory = m.contract("AvatarFactory", [acct, admins]);
    return {avatarFactory: Factory};
});