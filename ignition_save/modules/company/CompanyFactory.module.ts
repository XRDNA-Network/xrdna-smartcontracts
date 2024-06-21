import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {XRDNASigners} from '../../../src';
import {network} from 'hardhat';

export default buildModule("CompanyFactory", (m) => {
    
    const xrdna = new XRDNASigners();
    const config = xrdna.deployment[network.config.chainId || 55555];
    const acct = config.companyFactoryAdmin;
    const admins = config.companyFactoryOtherAdmins;
    const Factory = m.contract("CompanyFactory", [acct, admins]);
    return {companyFactory: Factory};
});