import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {XRDNASigners} from '../../../src';
import {network} from 'hardhat';

export default buildModule("PortalRegistry", (m) => {
    
    const xrdna = new XRDNASigners();
    const config = xrdna.deployment[network.config.chainId || 55555];
    const acct = config.portalRegistryAdmin;
    const admins = config.portalRegistryOtherAdmins;

    const Registry = m.contract("PortalRegistry", [acct, admins]);
    return {portalRegistry: Registry};
});