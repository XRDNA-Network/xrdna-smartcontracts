import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {abi as ABI} from '../../../../artifacts/contracts/registrar/registry/RegistrarRegistryProxy.sol/RegistrarRegistryProxy.json';
import { XRDNASigners } from "../../../../src";
import { network } from "hardhat";
import LibrariesModule from "../../Libraries.module";

export const abi = ABI;

export default buildModule("RegistrarRegistryProxyModule", (m) => {


    const xrdna = new XRDNASigners();
    const config = xrdna.deployment[network.config.chainId || 55555];
    const owner = config.registrarRegistryAdmin;
    const others = config.registrarRegistryOtherAdmins;

    const libs = m.useModule(LibrariesModule);

    const args = {
        owner,
        admins: others
    }
    const proxy = m.contract("RegistrarRegistryProxy", [args], {
        libraries: {
            LibAccess: libs.LibAccess,
        }
    });
    return {
        registrarRegistryProxy: proxy
    }
});