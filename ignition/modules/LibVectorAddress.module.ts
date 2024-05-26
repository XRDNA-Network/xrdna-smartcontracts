import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("LibVectorAddress", (m) => {
    const lib = m.contract("LibVectorAddress", []);
    return {libVectorAddress: lib};
});