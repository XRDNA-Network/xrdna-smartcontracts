import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {XRDNASigners} from '../../../src';
import {network} from 'hardhat';


export default buildModule("ExperienceFactory", (m) => {
    
    const xrdna = new XRDNASigners();
    const config = xrdna.deployment[network.config.chainId || 55555];
    const acct = config.experienceFactoryAdmin;
    const admins = config.experienceFactoryOtherAdmins;

    const Factory = m.contract("ExperienceFactory", [acct, admins]);
    return {experienceFactory: Factory};
});