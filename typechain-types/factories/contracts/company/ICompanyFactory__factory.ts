/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Interface, type ContractRunner } from "ethers";
import type {
  ICompanyFactory,
  ICompanyFactoryInterface,
} from "../../../contracts/company/ICompanyFactory";

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
            name: "world",
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
            name: "vector",
            type: "tuple",
          },
          {
            internalType: "bytes",
            name: "initData",
            type: "bytes",
          },
          {
            internalType: "string",
            name: "name",
            type: "string",
          },
        ],
        internalType: "struct CompanyInitArgs",
        name: "request",
        type: "tuple",
      },
    ],
    name: "createCompany",
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
] as const;

export class ICompanyFactory__factory {
  static readonly abi = _abi;
  static createInterface(): ICompanyFactoryInterface {
    return new Interface(_abi) as ICompanyFactoryInterface;
  }
  static connect(
    address: string,
    runner?: ContractRunner | null
  ): ICompanyFactory {
    return new Contract(address, _abi, runner) as unknown as ICompanyFactory;
  }
}
