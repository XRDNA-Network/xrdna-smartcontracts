/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Interface, type ContractRunner } from "ethers";
import type {
  IAssetCondition,
  IAssetConditionInterface,
} from "../../../contracts/asset/IAssetCondition";

const _abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "asset",
        type: "address",
      },
      {
        internalType: "address",
        name: "world",
        type: "address",
      },
      {
        internalType: "address",
        name: "company",
        type: "address",
      },
      {
        internalType: "address",
        name: "experience",
        type: "address",
      },
    ],
    name: "canUse",
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
        name: "asset",
        type: "address",
      },
      {
        internalType: "address",
        name: "world",
        type: "address",
      },
      {
        internalType: "address",
        name: "company",
        type: "address",
      },
      {
        internalType: "address",
        name: "experience",
        type: "address",
      },
    ],
    name: "canView",
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

export class IAssetCondition__factory {
  static readonly abi = _abi;
  static createInterface(): IAssetConditionInterface {
    return new Interface(_abi) as IAssetConditionInterface;
  }
  static connect(
    address: string,
    runner?: ContractRunner | null
  ): IAssetCondition {
    return new Contract(address, _abi, runner) as unknown as IAssetCondition;
  }
}