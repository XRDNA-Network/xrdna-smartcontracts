import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {XRDNASigners} from '../../src';
import {network} from 'hardhat';


export default buildModule("RegistrarRegistry", (m) => {
    
    const xrdna = new XRDNASigners();
    const config = xrdna.deployment[network.config.chainId || 55555];
    const acct = config.registrarRegistryAdmin;
    const regs = config.registrarRegistryOtherAdmins;
    const Registry = m.contract("RegistrarRegistry", [acct, regs]);
    return {registry: Registry};
});