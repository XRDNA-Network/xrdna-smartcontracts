/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Interface, type ContractRunner } from "ethers";
import type {
  IWorldFactory,
  IWorldFactoryInterface,
} from "../../../../contracts/world/v0.1/IWorldFactory";

const _abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "owner",
        type: "address",
      },
      {
        internalType: "bytes",
        name: "initData",
        type: "bytes",
      },
    ],
    name: "createWorld",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
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
    name: "isWorldClone",
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

export class IWorldFactory__factory {
  static readonly abi = _abi;
  static createInterface(): IWorldFactoryInterface {
    return new Interface(_abi) as IWorldFactoryInterface;
  }
  static connect(
    address: string,
    runner?: ContractRunner | null
  ): IWorldFactory {
    return new Contract(address, _abi, runner) as unknown as IWorldFactory;
  }
}
