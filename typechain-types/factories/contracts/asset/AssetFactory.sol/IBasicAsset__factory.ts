/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Interface, type ContractRunner } from "ethers";
import type {
  IBasicAsset,
  IBasicAssetInterface,
} from "../../../../contracts/asset/AssetFactory.sol/IBasicAsset";

const _abi = [
  {
    inputs: [
      {
        internalType: "bytes",
        name: "data",
        type: "bytes",
      },
    ],
    name: "init",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;

export class IBasicAsset__factory {
  static readonly abi = _abi;
  static createInterface(): IBasicAssetInterface {
    return new Interface(_abi) as IBasicAssetInterface;
  }
  static connect(address: string, runner?: ContractRunner | null): IBasicAsset {
    return new Contract(address, _abi, runner) as unknown as IBasicAsset;
  }
}