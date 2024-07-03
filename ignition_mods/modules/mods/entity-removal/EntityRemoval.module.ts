import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {abi as ABI} from '../../../../artifacts/contracts/modules/entity/removal/IEntityRemoval.sol/IEntityRemoval.json';
export const abi = ABI;

export default buildModule("EntityRemovalModule", (m) => {


        const er = m.contract("EntityRemovalModule", []);
        return {
            entityRemovalModule: er,
        }
});