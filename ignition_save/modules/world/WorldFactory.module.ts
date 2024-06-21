import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {XRDNASigners} from '../../../src';
import {network} from 'hardhat';

export default buildModule("WorldFactory", (m) => {
    
    const xrdna = new XRDNASigners();
    const config = xrdna.deployment[network.config.chainId || 55555];
    const acct = config.worldFactoryAdmin;
    const admins = config.worldFactoryOtherAdmins;
    const Factory = m.contract("WorldFactory", [acct, admins]);
    return {worldFactory: Factory};
});