/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Interface, type ContractRunner } from "ethers";
import type {
  IWorldRegistryV1,
  IWorldRegistryV1Interface,
} from "../../../../../contracts/world/v0.2/WorldRegistryV2.sol/IWorldRegistryV1";

const _abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "auth",
        type: "address",
      },
    ],
    name: "isVectorAddressAuthority",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "world",
        type: "address",
      },
    ],
    name: "isWorld",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
] as const;

export class IWorldRegistryV1__factory {
  static readonly abi = _abi;
  static createInterface(): IWorldRegistryV1Interface {
    return new Interface(_abi) as IWorldRegistryV1Interface;
  }
  static connect(
    address: string,
    runner?: ContractRunner | null
  ): IWorldRegistryV1 {
    return new Contract(address, _abi, runner) as unknown as IWorldRegistryV1;
  }
}