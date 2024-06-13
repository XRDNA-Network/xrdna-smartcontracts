import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {XRDNASigners} from '../../../../src';
import {network} from 'hardhat';

export default buildModule("ERC721AssetFactory", (m) => {
    
    const xrdna = new XRDNASigners();
    const deployConfig = xrdna.deployment[network.config.chainId || 55555];
    const acct = deployConfig.assetFactoryAdmin;
    const admins = deployConfig.assetFactoryOtherAdmins;
    const Factory = m.contract("ERC721AssetFactory", [acct, admins]);
    return {erc721Factory: Factory};
});