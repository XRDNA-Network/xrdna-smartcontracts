import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {config} from '../modules/config';


export default buildModule("RegistrarRegistry", (m) => {
    const regs = config.registerers;
    if(!regs || regs.length === 0) {
        throw new Error("Registerers not found");
    }
    const Registry = m.contract("RegistrarRegistry", [regs]);
    return {registry: Registry};
});