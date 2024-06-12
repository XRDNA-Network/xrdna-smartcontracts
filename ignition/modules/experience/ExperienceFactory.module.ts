import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {config} from "../config";

export default buildModule("ExperienceFactory", (m) => {
    
    const admins = config.experienceFactoryAdmins;
    const acct = m.getAccount(0);
    const Factory = m.contract("ExperienceFactory", [acct, admins]);
    return {experienceFactory: Factory};
});