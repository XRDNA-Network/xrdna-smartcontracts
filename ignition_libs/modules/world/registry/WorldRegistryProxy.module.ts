import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {abi as ABI} from '../../../../artifacts/contracts/world/registry/WorldRegistryProxy.sol/WorldRegistryProxy.json';
import { XRDNASigners } from "../../../../src";
import { network } from "hardhat";
import LibrariesModule from "../../Libraries.module";

export const abi = ABI;

export default buildModule("WorldRegistryProxyModule", (m) => {


    const xrdna = new XRDNASigners();
    const config = xrdna.deployment[network.config.chainId || 55555];
    const owner = config.worldRegistryAdmin;
    const others = config.worldRegistryOtherAdmins;

    const libs = m.useModule(LibrariesModule);

    const args = {
        owner,
        admins: others
    }
    const proxy = m.contract("WorldRegistryProxy", [args], {
        libraries: {
            LibAccess: libs.LibAccess
        }
    });
    return {
        worldRegistryProxy: proxy
    }
});