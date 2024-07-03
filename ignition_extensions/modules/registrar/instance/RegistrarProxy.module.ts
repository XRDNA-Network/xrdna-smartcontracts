import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import RegistrarFactoryModule from "../factory/RegistrarFactory.module";
import { generateABI } from "../../ABIBuilder";
import {abi} from '../../../../artifacts/contracts/registrar/instance/RegistrarProxy.sol/RegistrarProxy.json';
import LibrariesModule from "../../libraries/Libraries.module";


export default buildModule("RegistrarProxyModule", (m) => {
    
    const factory = m.useModule(RegistrarFactoryModule).registrarFactory;
    const libs = m.useModule(LibrariesModule);
    const reg = m.contract("RegistrarProxy", [factory], {
        libraries: {
            LibAccess: libs.LibAccess,
        },
        after: [
            factory,
            libs.LibAccess
        ]
    });
    generateABI({
        contractName: "RegistrarProxy",
        abi
    });
    m.call(factory, "setProxyImplementation", [reg])
    return {
        registrarProxy: reg
    };
});