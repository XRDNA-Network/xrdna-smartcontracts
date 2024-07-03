import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {abi as ABI} from '../../../../artifacts/contracts/registrar/instance/IRegistrar.sol/IRegistrar.json';
import {abi as pABI} from '../../../../artifacts/contracts/registrar/instance/RegistrarProxy.sol/RegistrarProxy.json';
import RegistrarProxyModule from "./RegistrarProxy.module";
import RegistrarRegistryModule from "../registry/RegistrarRegistry.module";
import LibrariesModule from "../../Libraries.module";
import RegistrarFactoryModule from "../../mods/registrar-factory/RegistrarFactory.module";

export const abi = [
    ...ABI,
    ...pABI
]

export default buildModule("RegistrarModule", (m) => {

    const proxy = m.useModule(RegistrarProxyModule).registrarProxy;
    const rReg = m.useModule(RegistrarRegistryModule).registrarRegistryProxy;
    const rFactoryMod = m.useModule(RegistrarFactoryModule)
    const libs = m.useModule(LibrariesModule);

    //make sure to use proxy addresses, not implementation addresses
    const args = {
        owningRegistry: rReg
    }
    const r = m.contract("Registrar", [args], {
        libraries: {
            LibAccess: libs.LibAccess,
            LibFunds: libs.LibFunds,
        },
        after: [
            rFactoryMod.registrarFactory,
            rReg
        ]
    });
    m.call(rFactoryMod.registrarFactory, "setEntityImplementation", [r]);
    return {
        registrar: r,
        registrarProxy: proxy
    }
});