/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Interface, type ContractRunner } from "ethers";
import type {
  IWorldHook,
  IWorldHookInterface,
} from "../../../../contracts/world/v0.2/IWorldHook";

const _abi = [
  {
    inputs: [
      {
        components: [
          {
            internalType: "bool",
            name: "sendTokensToAvatarOwner",
            type: "bool",
          },
          {
            internalType: "address",
            name: "avatarOwner",
            type: "address",
          },
          {
            internalType: "address",
            name: "defaultExperience",
            type: "address",
          },
          {
            internalType: "string",
            name: "username",
            type: "string",
          },
          {
            internalType: "bytes",
            name: "initData",
            type: "bytes",
          },
        ],
        internalType: "struct AvatarRegistrationRequest",
        name: "req",
        type: "tuple",
      },
    ],
    name: "beforeRegisterAvatar",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
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
        internalType: "struct CompanyRegistrationArgs",
        name: "args",
        type: "tuple",
      },
    ],
    name: "beforeRegisterCompany",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;

export class IWorldHook__factory {
  static readonly abi = _abi;
  static createInterface(): IWorldHookInterface {
    return new Interface(_abi) as IWorldHookInterface;
  }
  static connect(address: string, runner?: ContractRunner | null): IWorldHook {
    return new Contract(address, _abi, runner) as unknown as IWorldHook;
  }
}
