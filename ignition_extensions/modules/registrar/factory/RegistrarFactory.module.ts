import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {XRDNASigners} from '../../../../src';
import {network} from 'hardhat';
import Libraries from '../../libraries/Libraries.module';
import {generateABI} from '../../ABIBuilder';
import {abi} from '../../../../artifacts/contracts/registry/factory/interfaces/IEntityFactory.sol/IEntityFactory.json';

export default buildModule("RegistrarFactoryModule", (m) => {
    
    const libs = m.useModule(Libraries);

    const xrdna = new XRDNASigners();
    const config = xrdna.deployment[network.config.chainId || 55555];
    const acct = config.registrarFactoryAdmin;
    const others = config.registrarFactoryOtherAdmins;

    const args = {
        owner: acct,
        otherAdmins: others || []
    }

    const factory = m.contract("RegistrarFactory", [args], {
        libraries: {
            LibAccess: libs.LibAccess,
        },
        after: [
            libs.LibAccess,
        ]
    });
    generateABI({
        contractName: "RegistrarFactory",
        abi: abi
    })
    return {
        registrarFactory: factory
    };
});