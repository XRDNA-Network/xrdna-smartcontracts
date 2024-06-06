import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {config} from "../config";

export default buildModule("CompanyFactory", (m) => {
    
    const admins = config.companyFactoryAdmins;
    const acct = m.getAccount(0);
    const Factory = m.contract("CompanyFactory", [acct, admins]);
    return {companyFactory: Factory};
});