import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {abi as ABI} from '../../../../artifacts/contracts/registrar/instance/RegistrarProxy.sol/RegistrarProxy.json';
import RegistrarRegistryProxyModule from "../registry/RegistrarRegistryProxy.module";
import LibrariesModule from "../../Libraries.module";
import RegistrarFactoryModule from "../../mods/registrar-factory/RegistrarFactory.module";

export const abi = ABI;

export default buildModule("RegistrarProxyModule", (m) => {

    const rReg = m.useModule(RegistrarRegistryProxyModule).registrarRegistryProxy;
    const rFactoryMod = m.useModule(RegistrarFactoryModule)
    const libs = m.useModule(LibrariesModule);

    //use proxy address, not implementation
    const args = {
        owningRegistry: rReg 
    }
    const proxy = m.contract("RegistrarProxy", [args], {
        libraries: {
            LibAccess: libs.LibAccess
        },
        after: [
            rFactoryMod.registrarFactory,
            rReg,
        ]
    });
    m.call(rFactoryMod.registrarFactory, "setProxyImplementation", [proxy]);
    return {
        registrarProxy: proxy
    }
});