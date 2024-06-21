import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {XRDNASigners} from '../../../../src';
import {network} from 'hardhat';

export default buildModule("ERC20AssetFactory", (m) => {
    
    const xrdna = new XRDNASigners();
    const deployConfig = xrdna.deployment[network.config.chainId || 55555];
    const Factory = m.contract("ERC20AssetFactory", [deployConfig.assetFactoryAdmin, deployConfig.assetFactoryOtherAdmins]);
    return {erc20Factory: Factory};
});