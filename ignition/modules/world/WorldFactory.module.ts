import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {config} from "../config";

export default buildModule("WorldFactoryV2", (m) => {
    
    const admins = config.assetFactoryAdmins;
    const acct = m.getAccount(0);
    const Factory = m.contract("WorldFactoryV2", [acct, admins]);
    return {worldFactory: Factory};
});