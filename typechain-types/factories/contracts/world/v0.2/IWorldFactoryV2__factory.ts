/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Interface, type ContractRunner } from "ethers";
import type {
  IWorldFactoryV2,
  IWorldFactoryV2Interface,
} from "../../../../contracts/world/v0.2/IWorldFactoryV2";

const _abi = [
  {
    inputs: [
      {
        components: [
          {
            internalType: "address",
            name: "owner",
            type: "address",
          },
          {
            internalType: "address",
            name: "oldWorld",
            type: "address",
          },
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
            name: "baseVector",
            type: "tuple",
          },
          {
            internalType: "string",
            name: "name",
            type: "string",
          },
          {
            internalType: "bytes",
            name: "initData",
            type: "bytes",
          },
        ],
        internalType: "struct WorldCreateRequest",
        name: "request",
        type: "tuple",
      },
    ],
    name: "createWorld",
    outputs: [
      {
        internalType: "address",
        name: "world",
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
      {
        internalType: "bytes",
        name: "initData",
        type: "bytes",
      },
    ],
    name: "upgradeWorld",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;

export class IWorldFactoryV2__factory {
  static readonly abi = _abi;
  static createInterface(): IWorldFactoryV2Interface {
    return new Interface(_abi) as IWorldFactoryV2Interface;
  }
  static connect(
    address: string,
    runner?: ContractRunner | null
  ): IWorldFactoryV2 {
    return new Contract(address, _abi, runner) as unknown as IWorldFactoryV2;
  }
}