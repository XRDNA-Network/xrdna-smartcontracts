import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {config} from "../config";

export default buildModule("AssetFactory", (m) => {
    
    const admins = config.assetFactoryAdmins;
    const acct = m.getAccount(0);
    const Factory = m.contract("AssetFactory", [[acct, ...admins]]);
    return {assetFactory: Factory};
});