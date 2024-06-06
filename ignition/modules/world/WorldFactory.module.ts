import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {config} from "../config";

export default buildModule("WorldFactory0_2", (m) => {
    
    const admins = config.assetFactoryAdmins;
    const acct = m.getAccount(0);
    const Factory = m.contract("WorldFactory0_2", [acct, admins]);
    return {worldFactory: Factory};
});