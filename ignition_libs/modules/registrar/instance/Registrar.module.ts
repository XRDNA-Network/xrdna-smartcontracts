import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {abi as ABI} from '../../../../artifacts/contracts/registrar/interfaces/IRegistrar.sol/IRegistrar.json';
import {abi as pABI} from '../../../../artifacts/contracts/registrar/instance/RegistrarProxy.sol/RegistrarProxy.json';
import RegistrarProxyModule from "./RegistrarProxy.module";
import RegistrarRegistryModule from "../registry/RegistrarRegistry.module";
import LibrariesModule from "../../Libraries.module";
import WorldRegistryModule from "../../world/registry/WorldRegistry.module";

export const abi = [
    ...ABI,
    ...pABI
]

export default buildModule("RegistrarModule", (m) => {

    const proxy = m.useModule(RegistrarProxyModule).registrarProxy;
    const rReg = m.useModule(RegistrarRegistryModule);
    const libs = m.useModule(LibrariesModule);
    const wReg = m.useModule(WorldRegistryModule);

    //make sure to use proxy addresses, not implementation addresses
    const args = {
        owningRegistry: rReg.registrarRegistryProxy,
        worldRegistry: wReg.worldRegistryProxy
    }
    const r = m.contract("Registrar", [args], {
        libraries: {
            LibAccess: libs.LibAccess,
            LibRegistrar: libs.LibRegistrar
        },
        after: [
            libs.LibAccess,
            libs.LibRegistrar,
            rReg.registrarRegistry,
            wReg.worldRegistry
        ]
    });
    const data = m.encodeFunctionCall(rReg.registrarRegistry, "setEntityImplementation", [r]);
    m.send("setEntityImplementation", rReg.registrarRegistryProxy, 0n, data);
    return {
        registrar: r,
        registrarProxy: proxy
    }
});