import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {config} from '../modules/config';


export default buildModule("RegistrarRegistry", (m) => {
    const regs = config.registerers;
    if(!regs || regs.length === 0) {
        throw new Error("Registerers not found");
    }
    const acct = m.getAccount(0);
    const Registry = m.contract("RegistrarRegistry", [acct, regs]);
    return {registry: Registry};
});