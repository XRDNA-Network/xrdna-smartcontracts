import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {XRDNASigners} from '../../../src';
import {network} from 'hardhat';

export default buildModule("RegistrarFactory", (m) => {
    
    const xrdna = new XRDNASigners();
    const deployConfig = xrdna.deployment[network.config.chainId || 55555];
    const acct = deployConfig.registrarFactoryAdmin;
    const admins = deployConfig.registrarFactoryOtherAdmins;
    const Factory = m.contract("RegistrarFactory", [acct, admins]);
    return {registrarFactory: Factory};
});