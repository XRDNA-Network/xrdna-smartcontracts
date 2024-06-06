import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {config} from "../config";

export default buildModule("PortalRegistry", (m) => {
    
    const admins = config.portalRegistryAdmins;

    const acct = m.getAccount(0);

    const Registry = m.contract("PortalRegistry", [acct, admins]);
    return {portalRegistry: Registry};
});