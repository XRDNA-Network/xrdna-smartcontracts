import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {config} from "../config";

export default buildModule("AvatarFactory", (m) => {
    
    const admins = config.avatarFactoryAdmins;
    const acct = m.getAccount(0);
    const Factory = m.contract("AvatarFactory", [acct, admins]);
    return {avatarFactory: Factory};
});