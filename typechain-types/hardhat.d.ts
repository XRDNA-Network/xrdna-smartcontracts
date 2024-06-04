/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { ethers } from "ethers";
import {
  DeployContractOptions,
  FactoryOptions,
  HardhatEthersHelpers as HardhatEthersHelpersBase,
} from "@nomicfoundation/hardhat-ethers/types";

import * as Contracts from ".";

declare module "hardhat/types/runtime" {
  interface HardhatEthersHelpers extends HardhatEthersHelpersBase {
    getContractFactory(
      name: "AccessControl",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.AccessControl__factory>;
    getContractFactory(
      name: "IAccessControl",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IAccessControl__factory>;
    getContractFactory(
      name: "IERC1155Errors",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IERC1155Errors__factory>;
    getContractFactory(
      name: "IERC20Errors",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IERC20Errors__factory>;
    getContractFactory(
      name: "IERC721Errors",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IERC721Errors__factory>;
    getContractFactory(
      name: "IERC5267",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IERC5267__factory>;
    getContractFactory(
      name: "ERC20",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.ERC20__factory>;
    getContractFactory(
      name: "ERC20Permit",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.ERC20Permit__factory>;
    getContractFactory(
      name: "IERC20Metadata",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IERC20Metadata__factory>;
    getContractFactory(
      name: "IERC20Permit",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IERC20Permit__factory>;
    getContractFactory(
      name: "IERC20",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IERC20__factory>;
    getContractFactory(
      name: "IERC721Metadata",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IERC721Metadata__factory>;
    getContractFactory(
      name: "IERC721",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IERC721__factory>;
    getContractFactory(
      name: "IERC721Receiver",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IERC721Receiver__factory>;
    getContractFactory(
      name: "ECDSA",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.ECDSA__factory>;
    getContractFactory(
      name: "EIP712",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.EIP712__factory>;
    getContractFactory(
      name: "ERC165",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.ERC165__factory>;
    getContractFactory(
      name: "IERC165",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IERC165__factory>;
    getContractFactory(
      name: "Math",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.Math__factory>;
    getContractFactory(
      name: "Nonces",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.Nonces__factory>;
    getContractFactory(
      name: "ShortStrings",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.ShortStrings__factory>;
    getContractFactory(
      name: "Strings",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.Strings__factory>;
    getContractFactory(
      name: "AssetFactory",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.AssetFactory__factory>;
    getContractFactory(
      name: "IBasicAsset",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IBasicAsset__factory>;
    getContractFactory(
      name: "AssetRegistry",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.AssetRegistry__factory>;
    getContractFactory(
      name: "IBasicAsset",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IBasicAsset__factory>;
    getContractFactory(
      name: "IAssetCondition",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IAssetCondition__factory>;
    getContractFactory(
      name: "IAssetFactory",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IAssetFactory__factory>;
    getContractFactory(
      name: "IAssetHook",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IAssetHook__factory>;
    getContractFactory(
      name: "IAssetRegistry",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IAssetRegistry__factory>;
    getContractFactory(
      name: "NonTransferableERC20Asset",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.NonTransferableERC20Asset__factory>;
    getContractFactory(
      name: "IUpgradedERC721",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IUpgradedERC721__factory>;
    getContractFactory(
      name: "NonTransferableERC721Asset",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.NonTransferableERC721Asset__factory>;
    getContractFactory(
      name: "FilterByWorld",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.FilterByWorld__factory>;
    getContractFactory(
      name: "IRegistrarRegistry",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IRegistrarRegistry__factory>;
    getContractFactory(
      name: "RegistrarRegistry",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.RegistrarRegistry__factory>;
    getContractFactory(
      name: "IBasicWorld",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IBasicWorld__factory>;
    getContractFactory(
      name: "IWorld",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IWorld__factory>;
    getContractFactory(
      name: "IWorldFactory",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IWorldFactory__factory>;
    getContractFactory(
      name: "World",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.World__factory>;
    getContractFactory(
      name: "WorldFactory",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.WorldFactory__factory>;
    getContractFactory(
      name: "IWorldRegistry",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IWorldRegistry__factory>;
    getContractFactory(
      name: "WorldRegistry",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.WorldRegistry__factory>;
    getContractFactory(
      name: "XRDNAGasToken",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.XRDNAGasToken__factory>;

    getContractAt(
      name: "AccessControl",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.AccessControl>;
    getContractAt(
      name: "IAccessControl",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.IAccessControl>;
    getContractAt(
      name: "IERC1155Errors",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.IERC1155Errors>;
    getContractAt(
      name: "IERC20Errors",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.IERC20Errors>;
    getContractAt(
      name: "IERC721Errors",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.IERC721Errors>;
    getContractAt(
      name: "IERC5267",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.IERC5267>;
    getContractAt(
      name: "ERC20",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.ERC20>;
    getContractAt(
      name: "ERC20Permit",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.ERC20Permit>;
    getContractAt(
      name: "IERC20Metadata",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.IERC20Metadata>;
    getContractAt(
      name: "IERC20Permit",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.IERC20Permit>;
    getContractAt(
      name: "IERC20",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.IERC20>;
    getContractAt(
      name: "IERC721Metadata",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.IERC721Metadata>;
    getContractAt(
      name: "IERC721",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.IERC721>;
    getContractAt(
      name: "IERC721Receiver",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.IERC721Receiver>;
    getContractAt(
      name: "ECDSA",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.ECDSA>;
    getContractAt(
      name: "EIP712",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.EIP712>;
    getContractAt(
      name: "ERC165",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.ERC165>;
    getContractAt(
      name: "IERC165",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.IERC165>;
    getContractAt(
      name: "Math",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.Math>;
    getContractAt(
      name: "Nonces",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.Nonces>;
    getContractAt(
      name: "ShortStrings",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.ShortStrings>;
    getContractAt(
      name: "Strings",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.Strings>;
    getContractAt(
      name: "AssetFactory",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.AssetFactory>;
    getContractAt(
      name: "IBasicAsset",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.IBasicAsset>;
    getContractAt(
      name: "AssetRegistry",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.AssetRegistry>;
    getContractAt(
      name: "IBasicAsset",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.IBasicAsset>;
    getContractAt(
      name: "IAssetCondition",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.IAssetCondition>;
    getContractAt(
      name: "IAssetFactory",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.IAssetFactory>;
    getContractAt(
      name: "IAssetHook",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.IAssetHook>;
    getContractAt(
      name: "IAssetRegistry",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.IAssetRegistry>;
    getContractAt(
      name: "NonTransferableERC20Asset",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.NonTransferableERC20Asset>;
    getContractAt(
      name: "IUpgradedERC721",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.IUpgradedERC721>;
    getContractAt(
      name: "NonTransferableERC721Asset",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.NonTransferableERC721Asset>;
    getContractAt(
      name: "FilterByWorld",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.FilterByWorld>;
    getContractAt(
      name: "IRegistrarRegistry",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.IRegistrarRegistry>;
    getContractAt(
      name: "RegistrarRegistry",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.RegistrarRegistry>;
    getContractAt(
      name: "IBasicWorld",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.IBasicWorld>;
    getContractAt(
      name: "IWorld",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.IWorld>;
    getContractAt(
      name: "IWorldFactory",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.IWorldFactory>;
    getContractAt(
      name: "World",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.World>;
    getContractAt(
      name: "WorldFactory",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.WorldFactory>;
    getContractAt(
      name: "IWorldRegistry",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.IWorldRegistry>;
    getContractAt(
      name: "WorldRegistry",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.WorldRegistry>;
    getContractAt(
      name: "XRDNAGasToken",
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<Contracts.XRDNAGasToken>;

    deployContract(
      name: "AccessControl",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.AccessControl>;
    deployContract(
      name: "IAccessControl",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IAccessControl>;
    deployContract(
      name: "IERC1155Errors",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IERC1155Errors>;
    deployContract(
      name: "IERC20Errors",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IERC20Errors>;
    deployContract(
      name: "IERC721Errors",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IERC721Errors>;
    deployContract(
      name: "IERC5267",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IERC5267>;
    deployContract(
      name: "ERC20",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.ERC20>;
    deployContract(
      name: "ERC20Permit",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.ERC20Permit>;
    deployContract(
      name: "IERC20Metadata",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IERC20Metadata>;
    deployContract(
      name: "IERC20Permit",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IERC20Permit>;
    deployContract(
      name: "IERC20",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IERC20>;
    deployContract(
      name: "IERC721Metadata",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IERC721Metadata>;
    deployContract(
      name: "IERC721",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IERC721>;
    deployContract(
      name: "IERC721Receiver",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IERC721Receiver>;
    deployContract(
      name: "ECDSA",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.ECDSA>;
    deployContract(
      name: "EIP712",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.EIP712>;
    deployContract(
      name: "ERC165",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.ERC165>;
    deployContract(
      name: "IERC165",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IERC165>;
    deployContract(
      name: "Math",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.Math>;
    deployContract(
      name: "Nonces",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.Nonces>;
    deployContract(
      name: "ShortStrings",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.ShortStrings>;
    deployContract(
      name: "Strings",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.Strings>;
    deployContract(
      name: "AssetFactory",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.AssetFactory>;
    deployContract(
      name: "IBasicAsset",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IBasicAsset>;
    deployContract(
      name: "AssetRegistry",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.AssetRegistry>;
    deployContract(
      name: "IBasicAsset",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IBasicAsset>;
    deployContract(
      name: "IAssetCondition",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IAssetCondition>;
    deployContract(
      name: "IAssetFactory",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IAssetFactory>;
    deployContract(
      name: "IAssetHook",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IAssetHook>;
    deployContract(
      name: "IAssetRegistry",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IAssetRegistry>;
    deployContract(
      name: "NonTransferableERC20Asset",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.NonTransferableERC20Asset>;
    deployContract(
      name: "IUpgradedERC721",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IUpgradedERC721>;
    deployContract(
      name: "NonTransferableERC721Asset",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.NonTransferableERC721Asset>;
    deployContract(
      name: "FilterByWorld",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.FilterByWorld>;
    deployContract(
      name: "IRegistrarRegistry",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IRegistrarRegistry>;
    deployContract(
      name: "RegistrarRegistry",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.RegistrarRegistry>;
    deployContract(
      name: "IBasicWorld",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IBasicWorld>;
    deployContract(
      name: "IWorld",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IWorld>;
    deployContract(
      name: "IWorldFactory",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IWorldFactory>;
    deployContract(
      name: "World",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.World>;
    deployContract(
      name: "WorldFactory",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.WorldFactory>;
    deployContract(
      name: "IWorldRegistry",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IWorldRegistry>;
    deployContract(
      name: "WorldRegistry",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.WorldRegistry>;
    deployContract(
      name: "XRDNAGasToken",
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.XRDNAGasToken>;

    deployContract(
      name: "AccessControl",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.AccessControl>;
    deployContract(
      name: "IAccessControl",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IAccessControl>;
    deployContract(
      name: "IERC1155Errors",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IERC1155Errors>;
    deployContract(
      name: "IERC20Errors",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IERC20Errors>;
    deployContract(
      name: "IERC721Errors",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IERC721Errors>;
    deployContract(
      name: "IERC5267",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IERC5267>;
    deployContract(
      name: "ERC20",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.ERC20>;
    deployContract(
      name: "ERC20Permit",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.ERC20Permit>;
    deployContract(
      name: "IERC20Metadata",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IERC20Metadata>;
    deployContract(
      name: "IERC20Permit",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IERC20Permit>;
    deployContract(
      name: "IERC20",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IERC20>;
    deployContract(
      name: "IERC721Metadata",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IERC721Metadata>;
    deployContract(
      name: "IERC721",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IERC721>;
    deployContract(
      name: "IERC721Receiver",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IERC721Receiver>;
    deployContract(
      name: "ECDSA",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.ECDSA>;
    deployContract(
      name: "EIP712",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.EIP712>;
    deployContract(
      name: "ERC165",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.ERC165>;
    deployContract(
      name: "IERC165",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IERC165>;
    deployContract(
      name: "Math",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.Math>;
    deployContract(
      name: "Nonces",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.Nonces>;
    deployContract(
      name: "ShortStrings",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.ShortStrings>;
    deployContract(
      name: "Strings",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.Strings>;
    deployContract(
      name: "AssetFactory",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.AssetFactory>;
    deployContract(
      name: "IBasicAsset",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IBasicAsset>;
    deployContract(
      name: "AssetRegistry",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.AssetRegistry>;
    deployContract(
      name: "IBasicAsset",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IBasicAsset>;
    deployContract(
      name: "IAssetCondition",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IAssetCondition>;
    deployContract(
      name: "IAssetFactory",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IAssetFactory>;
    deployContract(
      name: "IAssetHook",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IAssetHook>;
    deployContract(
      name: "IAssetRegistry",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IAssetRegistry>;
    deployContract(
      name: "NonTransferableERC20Asset",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.NonTransferableERC20Asset>;
    deployContract(
      name: "IUpgradedERC721",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IUpgradedERC721>;
    deployContract(
      name: "NonTransferableERC721Asset",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.NonTransferableERC721Asset>;
    deployContract(
      name: "FilterByWorld",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.FilterByWorld>;
    deployContract(
      name: "IRegistrarRegistry",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IRegistrarRegistry>;
    deployContract(
      name: "RegistrarRegistry",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.RegistrarRegistry>;
    deployContract(
      name: "IBasicWorld",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IBasicWorld>;
    deployContract(
      name: "IWorld",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IWorld>;
    deployContract(
      name: "IWorldFactory",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IWorldFactory>;
    deployContract(
      name: "World",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.World>;
    deployContract(
      name: "WorldFactory",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.WorldFactory>;
    deployContract(
      name: "IWorldRegistry",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.IWorldRegistry>;
    deployContract(
      name: "WorldRegistry",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.WorldRegistry>;
    deployContract(
      name: "XRDNAGasToken",
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<Contracts.XRDNAGasToken>;

    // default types
    getContractFactory(
      name: string,
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<ethers.ContractFactory>;
    getContractFactory(
      abi: any[],
      bytecode: ethers.BytesLike,
      signer?: ethers.Signer
    ): Promise<ethers.ContractFactory>;
    getContractAt(
      nameOrAbi: string | any[],
      address: string | ethers.Addressable,
      signer?: ethers.Signer
    ): Promise<ethers.Contract>;
    deployContract(
      name: string,
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<ethers.Contract>;
    deployContract(
      name: string,
      args: any[],
      signerOrOptions?: ethers.Signer | DeployContractOptions
    ): Promise<ethers.Contract>;
  }
}
