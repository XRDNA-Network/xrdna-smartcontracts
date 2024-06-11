import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {config} from "../../config";

export default buildModule("ERC20AssetFactory", (m) => {
    
    const admins = config.assetFactoryAdmins;
    const acct = m.getAccount(0);
    const Factory = m.contract("ERC20AssetFactory", [acct, admins]);
    return {erc20Factory: Factory};
});