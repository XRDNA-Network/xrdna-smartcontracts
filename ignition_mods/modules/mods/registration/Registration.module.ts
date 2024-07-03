import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {abi as ABI} from '../../../../artifacts/contracts/modules/registration/IRegistration.sol/IRegistration.json';

export const abi = ABI;

export default buildModule("RegistrarRegistrationModule", (m) => {
    const rm = m.contract("RegistrationModule", []);
    return {
        registrationModule: rm
    }
});