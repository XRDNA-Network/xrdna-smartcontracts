import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {abi as ABI} from '../../../../artifacts/contracts/modules/control-change/IControlChange.sol/IControlChange.json';
export const abi = ABI;

export default buildModule("ControlChangeModuleModule", (m) => {

        const cc = m.contract("ControlChangeModule", []);
        return {
            controlChangeModule: cc
        }
});