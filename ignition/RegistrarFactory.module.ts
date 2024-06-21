import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("RegistrarFactory", (m) => {

    const fac = m.contract("RegistrarFactory");
    return {registrarFactory: fac};
});