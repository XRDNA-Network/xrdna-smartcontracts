/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Interface, type ContractRunner } from "ethers";
import type {
  IWorldFactory0_2,
  IWorldFactory0_2Interface,
} from "../../../../contracts/world/v0.2/IWorldFactory0_2";

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
] as const;

export class IWorldFactory0_2__factory {
  static readonly abi = _abi;
  static createInterface(): IWorldFactory0_2Interface {
    return new Interface(_abi) as IWorldFactory0_2Interface;
  }
  static connect(
    address: string,
    runner?: ContractRunner | null
  ): IWorldFactory0_2 {
    return new Contract(address, _abi, runner) as unknown as IWorldFactory0_2;
  }
}
