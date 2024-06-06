/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Interface, type ContractRunner } from "ethers";
import type {
  IBasicCompany,
  IBasicCompanyInterface,
} from "../../../contracts/experience/IBasicCompany";

const _abi = [
  {
    inputs: [],
    name: "vectorAddress",
    outputs: [
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
        name: "",
        type: "tuple",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "world",
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

export class IBasicCompany__factory {
  static readonly abi = _abi;
  static createInterface(): IBasicCompanyInterface {
    return new Interface(_abi) as IBasicCompanyInterface;
  }
  static connect(
    address: string,
    runner?: ContractRunner | null
  ): IBasicCompany {
    return new Contract(address, _abi, runner) as unknown as IBasicCompany;
  }
}
