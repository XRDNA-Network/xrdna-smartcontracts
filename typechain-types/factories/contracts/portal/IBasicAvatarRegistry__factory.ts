/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Interface, type ContractRunner } from "ethers";
import type {
  IBasicAvatarRegistry,
  IBasicAvatarRegistryInterface,
} from "../../../contracts/portal/IBasicAvatarRegistry";

const _abi = [
  {
    inputs: [
      {
        components: [
          {
            internalType: "string",
            name: "x",
            type: "string",
          },
          {
            internalType: "string",
            name: "y",
            type: "string",
          },
          {
            internalType: "string",
            name: "z",
            type: "string",
          },
          {
            internalType: "uint256",
            name: "t",
            type: "uint256",
          },
          {
            internalType: "uint256",
            name: "p",
            type: "uint256",
          },
          {
            internalType: "uint256",
            name: "p_sub",
            type: "uint256",
          },
        ],
        internalType: "struct VectorAddress",
        name: "location",
        type: "tuple",
      },
    ],
    name: "findAvatarByCurrentLocation",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "owner",
        type: "address",
      },
    ],
    name: "findAvatarByOwner",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
] as const;

export class IBasicAvatarRegistry__factory {
  static readonly abi = _abi;
  static createInterface(): IBasicAvatarRegistryInterface {
    return new Interface(_abi) as IBasicAvatarRegistryInterface;
  }
  static connect(
    address: string,
    runner?: ContractRunner | null
  ): IBasicAvatarRegistry {
    return new Contract(
      address,
      _abi,
      runner
    ) as unknown as IBasicAvatarRegistry;
  }
}