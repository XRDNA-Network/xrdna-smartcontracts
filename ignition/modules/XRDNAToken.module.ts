import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {config} from './config';

export default buildModule("XRDNAGasToken", (m) => {
    const minters = config.minters;
    if(!minters || minters.length === 0) {
        throw new Error("Minters not found");
    }
    const acct = m.getAccount(0);
    console.log("Deploying with minters", minters);
    const XRDNAGasToken = m.contract("XRDNAGasToken", [acct, minters]);
    return {token: XRDNAGasToken};
});