import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Libraries", (m) => {

        const libMixin = m.library("LibMixin");
        const libSigners = m.library("LibSigners");
        const libHook = m.library("LibHook");
        const libFunds = m.library("LibFunds");
        const libRegistration = m.library("LibRegistration");

        return {
            LibMixin: libMixin,
            LibSigners: libSigners,
            LibHook: libHook,
            LibFunds: libFunds,
            LibRegistration: libRegistration
        }
});