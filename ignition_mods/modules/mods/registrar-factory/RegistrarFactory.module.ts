import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {abi as ABI} from '../../../../artifacts/contracts/modules/registrar-factory/IRegistrarFactory.sol/IRegistrarFactory.json';
import LibrariesModule from "../../Libraries.module";
import { XRDNASigners } from "../../../../src";
import { network } from "hardhat";

export const abi = ABI;

export default buildModule("RegistrarFactoryModule", (m) => {

    const xrdna = new XRDNASigners();
    const config = xrdna.deployment[network.config.chainId || 55555];
    const owner = config.registrarFactoryAdmin;
    const others = config.registrarFactoryOtherAdmins;


    const libs = m.useModule(LibrariesModule);
    const args = {
        owner,
        admins: others
    }

    const rf = m.contract("RegistrarFactory", [args], {
        libraries: {
            LibAccess: libs.LibAccess
        }
    
    });
    return {
        registrarFactory: rf
    }
});