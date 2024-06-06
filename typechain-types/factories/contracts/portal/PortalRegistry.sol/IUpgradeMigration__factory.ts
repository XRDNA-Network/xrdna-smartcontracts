/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Interface, type ContractRunner } from "ethers";
import type {
  IUpgradeMigration,
  IUpgradeMigrationInterface,
} from "../../../../contracts/portal/PortalRegistry.sol/IUpgradeMigration";

const _abi = [
  {
    inputs: [
      {
        internalType: "uint256",
        name: "counter",
        type: "uint256",
      },
    ],
    name: "setStartingPortalIdCounter",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;

export class IUpgradeMigration__factory {
  static readonly abi = _abi;
  static createInterface(): IUpgradeMigrationInterface {
    return new Interface(_abi) as IUpgradeMigrationInterface;
  }
  static connect(
    address: string,
    runner?: ContractRunner | null
  ): IUpgradeMigration {
    return new Contract(address, _abi, runner) as unknown as IUpgradeMigration;
  }
}
