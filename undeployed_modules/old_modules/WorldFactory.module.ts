
import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {config} from "../modules/config";

export default buildModule("WorldFactory", (m) => {
    
    const admins = config.worldFactoryAdmins;
    const acct = m.getAccount(0);
    const Factory = m.contract("WorldFactory", [[acct, ...admins]]);
    return {worldFactory: Factory};
});