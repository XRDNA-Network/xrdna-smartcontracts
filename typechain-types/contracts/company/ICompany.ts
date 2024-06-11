/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import type {
  BaseContract,
  BigNumberish,
  BytesLike,
  FunctionFragment,
  Result,
  Interface,
  EventFragment,
  AddressLike,
  ContractRunner,
  ContractMethod,
  Listener,
} from "ethers";
import type {
  TypedContractEvent,
  TypedDeferredTopicFilter,
  TypedEventLog,
  TypedLogDescription,
  TypedListener,
  TypedContractMethod,
} from "../../common";

export type AddExperienceArgsStruct = { name: string; initData: BytesLike };

export type AddExperienceArgsStructOutput = [name: string, initData: string] & {
  name: string;
  initData: string;
};

export type DelegatedAvatarJumpRequestStruct = {
  avatar: AddressLike;
  portalId: BigNumberish;
  agreedFee: BigNumberish;
  avatarOwnerSignature: BytesLike;
};

export type DelegatedAvatarJumpRequestStructOutput = [
  avatar: string,
  portalId: bigint,
  agreedFee: bigint,
  avatarOwnerSignature: string
] & {
  avatar: string;
  portalId: bigint;
  agreedFee: bigint;
  avatarOwnerSignature: string;
};

export type VectorAddressStruct = {
  x: string;
  y: string;
  z: string;
  t: BigNumberish;
  p: BigNumberish;
  p_sub: BigNumberish;
};

export type VectorAddressStructOutput = [
  x: string,
  y: string,
  z: string,
  t: bigint,
  p: bigint,
  p_sub: bigint
] & { x: string; y: string; z: string; t: bigint; p: bigint; p_sub: bigint };

export type CompanyInitArgsStruct = {
  owner: AddressLike;
  world: AddressLike;
  vector: VectorAddressStruct;
  initData: BytesLike;
  name: string;
};

export type CompanyInitArgsStructOutput = [
  owner: string,
  world: string,
  vector: VectorAddressStructOutput,
  initData: string,
  name: string
] & {
  owner: string;
  world: string;
  vector: VectorAddressStructOutput;
  initData: string;
  name: string;
};

export interface ICompanyInterface extends Interface {
  getFunction(
    nameOrSignature:
      | "addAssetHook"
      | "addExperience"
      | "addExperienceCondition"
      | "addSigner"
      | "canMint"
      | "delegateJumpForAvatar"
      | "init"
      | "isSigner"
      | "mint"
      | "name"
      | "owner"
      | "removeAssetHook"
      | "removeExperienceCondition"
      | "removeHook"
      | "removeSigner"
      | "revoke"
      | "setHook"
      | "upgrade"
      | "upgradeComplete"
      | "upgraded"
      | "vectorAddress"
      | "version"
      | "withdraw"
      | "world"
  ): FunctionFragment;

  getEvent(
    nameOrSignatureOrTopic:
      | "AssetMinted"
      | "AssetRevoked"
      | "CompanyHookRemoved"
      | "CompanyHookSet"
      | "CompanyUpgraded"
      | "ExperienceAdded"
      | "SignerAdded"
      | "SignerRemoved"
  ): EventFragment;

  encodeFunctionData(
    functionFragment: "addAssetHook",
    values: [AddressLike, AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "addExperience",
    values: [AddExperienceArgsStruct]
  ): string;
  encodeFunctionData(
    functionFragment: "addExperienceCondition",
    values: [AddressLike, AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "addSigner",
    values: [AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "canMint",
    values: [AddressLike, AddressLike, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "delegateJumpForAvatar",
    values: [DelegatedAvatarJumpRequestStruct]
  ): string;
  encodeFunctionData(
    functionFragment: "init",
    values: [CompanyInitArgsStruct]
  ): string;
  encodeFunctionData(
    functionFragment: "isSigner",
    values: [AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "mint",
    values: [AddressLike, AddressLike, BigNumberish]
  ): string;
  encodeFunctionData(functionFragment: "name", values?: undefined): string;
  encodeFunctionData(functionFragment: "owner", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "removeAssetHook",
    values: [AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "removeExperienceCondition",
    values: [AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "removeHook",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "removeSigner",
    values: [AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "revoke",
    values: [AddressLike, AddressLike, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "setHook",
    values: [AddressLike]
  ): string;
  encodeFunctionData(functionFragment: "upgrade", values: [BytesLike]): string;
  encodeFunctionData(
    functionFragment: "upgradeComplete",
    values: [AddressLike]
  ): string;
  encodeFunctionData(functionFragment: "upgraded", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "vectorAddress",
    values?: undefined
  ): string;
  encodeFunctionData(functionFragment: "version", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "withdraw",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(functionFragment: "world", values?: undefined): string;

  decodeFunctionResult(
    functionFragment: "addAssetHook",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "addExperience",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "addExperienceCondition",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "addSigner", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "canMint", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "delegateJumpForAvatar",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "init", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "isSigner", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "mint", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "name", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "owner", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "removeAssetHook",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "removeExperienceCondition",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "removeHook", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "removeSigner",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "revoke", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "setHook", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "upgrade", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "upgradeComplete",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "upgraded", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "vectorAddress",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "version", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "withdraw", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "world", data: BytesLike): Result;
}

export namespace AssetMintedEvent {
  export type InputTuple = [
    asset: AddressLike,
    to: AddressLike,
    amountOrTokenId: BigNumberish
  ];
  export type OutputTuple = [
    asset: string,
    to: string,
    amountOrTokenId: bigint
  ];
  export interface OutputObject {
    asset: string;
    to: string;
    amountOrTokenId: bigint;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export namespace AssetRevokedEvent {
  export type InputTuple = [
    asset: AddressLike,
    holder: AddressLike,
    amountOrTokenId: BigNumberish
  ];
  export type OutputTuple = [
    asset: string,
    holder: string,
    amountOrTokenId: bigint
  ];
  export interface OutputObject {
    asset: string;
    holder: string;
    amountOrTokenId: bigint;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export namespace CompanyHookRemovedEvent {
  export type InputTuple = [];
  export type OutputTuple = [];
  export interface OutputObject {}
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export namespace CompanyHookSetEvent {
  export type InputTuple = [hook: AddressLike];
  export type OutputTuple = [hook: string];
  export interface OutputObject {
    hook: string;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export namespace CompanyUpgradedEvent {
  export type InputTuple = [oldVersion: AddressLike, nextVersion: AddressLike];
  export type OutputTuple = [oldVersion: string, nextVersion: string];
  export interface OutputObject {
    oldVersion: string;
    nextVersion: string;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export namespace ExperienceAddedEvent {
  export type InputTuple = [experience: AddressLike, portalId: BigNumberish];
  export type OutputTuple = [experience: string, portalId: bigint];
  export interface OutputObject {
    experience: string;
    portalId: bigint;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export namespace SignerAddedEvent {
  export type InputTuple = [signer: AddressLike];
  export type OutputTuple = [signer: string];
  export interface OutputObject {
    signer: string;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export namespace SignerRemovedEvent {
  export type InputTuple = [signer: AddressLike];
  export type OutputTuple = [signer: string];
  export interface OutputObject {
    signer: string;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export interface ICompany extends BaseContract {
  connect(runner?: ContractRunner | null): ICompany;
  waitForDeployment(): Promise<this>;

  interface: ICompanyInterface;

  queryFilter<TCEvent extends TypedContractEvent>(
    event: TCEvent,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined
  ): Promise<Array<TypedEventLog<TCEvent>>>;
  queryFilter<TCEvent extends TypedContractEvent>(
    filter: TypedDeferredTopicFilter<TCEvent>,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined
  ): Promise<Array<TypedEventLog<TCEvent>>>;

  on<TCEvent extends TypedContractEvent>(
    event: TCEvent,
    listener: TypedListener<TCEvent>
  ): Promise<this>;
  on<TCEvent extends TypedContractEvent>(
    filter: TypedDeferredTopicFilter<TCEvent>,
    listener: TypedListener<TCEvent>
  ): Promise<this>;

  once<TCEvent extends TypedContractEvent>(
    event: TCEvent,
    listener: TypedListener<TCEvent>
  ): Promise<this>;
  once<TCEvent extends TypedContractEvent>(
    filter: TypedDeferredTopicFilter<TCEvent>,
    listener: TypedListener<TCEvent>
  ): Promise<this>;

  listeners<TCEvent extends TypedContractEvent>(
    event: TCEvent
  ): Promise<Array<TypedListener<TCEvent>>>;
  listeners(eventName?: string): Promise<Array<Listener>>;
  removeAllListeners<TCEvent extends TypedContractEvent>(
    event?: TCEvent
  ): Promise<this>;

  addAssetHook: TypedContractMethod<
    [asset: AddressLike, hook: AddressLike],
    [void],
    "nonpayable"
  >;

  addExperience: TypedContractMethod<
    [args: AddExperienceArgsStruct],
    [void],
    "nonpayable"
  >;

  addExperienceCondition: TypedContractMethod<
    [experience: AddressLike, condition: AddressLike],
    [void],
    "nonpayable"
  >;

  addSigner: TypedContractMethod<[signer: AddressLike], [void], "nonpayable">;

  canMint: TypedContractMethod<
    [asset: AddressLike, to: AddressLike, amount: BigNumberish],
    [boolean],
    "view"
  >;

  delegateJumpForAvatar: TypedContractMethod<
    [request: DelegatedAvatarJumpRequestStruct],
    [void],
    "payable"
  >;

  init: TypedContractMethod<
    [args: CompanyInitArgsStruct],
    [void],
    "nonpayable"
  >;

  isSigner: TypedContractMethod<[signer: AddressLike], [boolean], "view">;

  mint: TypedContractMethod<
    [asset: AddressLike, to: AddressLike, amount: BigNumberish],
    [void],
    "nonpayable"
  >;

  name: TypedContractMethod<[], [string], "view">;

  owner: TypedContractMethod<[], [string], "view">;

  removeAssetHook: TypedContractMethod<
    [asset: AddressLike],
    [void],
    "nonpayable"
  >;

  removeExperienceCondition: TypedContractMethod<
    [experience: AddressLike],
    [void],
    "nonpayable"
  >;

  removeHook: TypedContractMethod<[], [void], "nonpayable">;

  removeSigner: TypedContractMethod<
    [signer: AddressLike],
    [void],
    "nonpayable"
  >;

  revoke: TypedContractMethod<
    [asset: AddressLike, holder: AddressLike, amountOrTokenId: BigNumberish],
    [void],
    "nonpayable"
  >;

  setHook: TypedContractMethod<[hook: AddressLike], [void], "nonpayable">;

  upgrade: TypedContractMethod<[initData: BytesLike], [void], "nonpayable">;

  upgradeComplete: TypedContractMethod<
    [nextVersion: AddressLike],
    [void],
    "nonpayable"
  >;

  upgraded: TypedContractMethod<[], [boolean], "view">;

  vectorAddress: TypedContractMethod<[], [VectorAddressStructOutput], "view">;

  version: TypedContractMethod<[], [bigint], "view">;

  withdraw: TypedContractMethod<[amount: BigNumberish], [void], "nonpayable">;

  world: TypedContractMethod<[], [string], "view">;

  getFunction<T extends ContractMethod = ContractMethod>(
    key: string | FunctionFragment
  ): T;

  getFunction(
    nameOrSignature: "addAssetHook"
  ): TypedContractMethod<
    [asset: AddressLike, hook: AddressLike],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "addExperience"
  ): TypedContractMethod<[args: AddExperienceArgsStruct], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "addExperienceCondition"
  ): TypedContractMethod<
    [experience: AddressLike, condition: AddressLike],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "addSigner"
  ): TypedContractMethod<[signer: AddressLike], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "canMint"
  ): TypedContractMethod<
    [asset: AddressLike, to: AddressLike, amount: BigNumberish],
    [boolean],
    "view"
  >;
  getFunction(
    nameOrSignature: "delegateJumpForAvatar"
  ): TypedContractMethod<
    [request: DelegatedAvatarJumpRequestStruct],
    [void],
    "payable"
  >;
  getFunction(
    nameOrSignature: "init"
  ): TypedContractMethod<[args: CompanyInitArgsStruct], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "isSigner"
  ): TypedContractMethod<[signer: AddressLike], [boolean], "view">;
  getFunction(
    nameOrSignature: "mint"
  ): TypedContractMethod<
    [asset: AddressLike, to: AddressLike, amount: BigNumberish],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "name"
  ): TypedContractMethod<[], [string], "view">;
  getFunction(
    nameOrSignature: "owner"
  ): TypedContractMethod<[], [string], "view">;
  getFunction(
    nameOrSignature: "removeAssetHook"
  ): TypedContractMethod<[asset: AddressLike], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "removeExperienceCondition"
  ): TypedContractMethod<[experience: AddressLike], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "removeHook"
  ): TypedContractMethod<[], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "removeSigner"
  ): TypedContractMethod<[signer: AddressLike], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "revoke"
  ): TypedContractMethod<
    [asset: AddressLike, holder: AddressLike, amountOrTokenId: BigNumberish],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "setHook"
  ): TypedContractMethod<[hook: AddressLike], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "upgrade"
  ): TypedContractMethod<[initData: BytesLike], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "upgradeComplete"
  ): TypedContractMethod<[nextVersion: AddressLike], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "upgraded"
  ): TypedContractMethod<[], [boolean], "view">;
  getFunction(
    nameOrSignature: "vectorAddress"
  ): TypedContractMethod<[], [VectorAddressStructOutput], "view">;
  getFunction(
    nameOrSignature: "version"
  ): TypedContractMethod<[], [bigint], "view">;
  getFunction(
    nameOrSignature: "withdraw"
  ): TypedContractMethod<[amount: BigNumberish], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "world"
  ): TypedContractMethod<[], [string], "view">;

  getEvent(
    key: "AssetMinted"
  ): TypedContractEvent<
    AssetMintedEvent.InputTuple,
    AssetMintedEvent.OutputTuple,
    AssetMintedEvent.OutputObject
  >;
  getEvent(
    key: "AssetRevoked"
  ): TypedContractEvent<
    AssetRevokedEvent.InputTuple,
    AssetRevokedEvent.OutputTuple,
    AssetRevokedEvent.OutputObject
  >;
  getEvent(
    key: "CompanyHookRemoved"
  ): TypedContractEvent<
    CompanyHookRemovedEvent.InputTuple,
    CompanyHookRemovedEvent.OutputTuple,
    CompanyHookRemovedEvent.OutputObject
  >;
  getEvent(
    key: "CompanyHookSet"
  ): TypedContractEvent<
    CompanyHookSetEvent.InputTuple,
    CompanyHookSetEvent.OutputTuple,
    CompanyHookSetEvent.OutputObject
  >;
  getEvent(
    key: "CompanyUpgraded"
  ): TypedContractEvent<
    CompanyUpgradedEvent.InputTuple,
    CompanyUpgradedEvent.OutputTuple,
    CompanyUpgradedEvent.OutputObject
  >;
  getEvent(
    key: "ExperienceAdded"
  ): TypedContractEvent<
    ExperienceAddedEvent.InputTuple,
    ExperienceAddedEvent.OutputTuple,
    ExperienceAddedEvent.OutputObject
  >;
  getEvent(
    key: "SignerAdded"
  ): TypedContractEvent<
    SignerAddedEvent.InputTuple,
    SignerAddedEvent.OutputTuple,
    SignerAddedEvent.OutputObject
  >;
  getEvent(
    key: "SignerRemoved"
  ): TypedContractEvent<
    SignerRemovedEvent.InputTuple,
    SignerRemovedEvent.OutputTuple,
    SignerRemovedEvent.OutputObject
  >;

  filters: {
    "AssetMinted(address,address,uint256)": TypedContractEvent<
      AssetMintedEvent.InputTuple,
      AssetMintedEvent.OutputTuple,
      AssetMintedEvent.OutputObject
    >;
    AssetMinted: TypedContractEvent<
      AssetMintedEvent.InputTuple,
      AssetMintedEvent.OutputTuple,
      AssetMintedEvent.OutputObject
    >;

    "AssetRevoked(address,address,uint256)": TypedContractEvent<
      AssetRevokedEvent.InputTuple,
      AssetRevokedEvent.OutputTuple,
      AssetRevokedEvent.OutputObject
    >;
    AssetRevoked: TypedContractEvent<
      AssetRevokedEvent.InputTuple,
      AssetRevokedEvent.OutputTuple,
      AssetRevokedEvent.OutputObject
    >;

    "CompanyHookRemoved()": TypedContractEvent<
      CompanyHookRemovedEvent.InputTuple,
      CompanyHookRemovedEvent.OutputTuple,
      CompanyHookRemovedEvent.OutputObject
    >;
    CompanyHookRemoved: TypedContractEvent<
      CompanyHookRemovedEvent.InputTuple,
      CompanyHookRemovedEvent.OutputTuple,
      CompanyHookRemovedEvent.OutputObject
    >;

    "CompanyHookSet(address)": TypedContractEvent<
      CompanyHookSetEvent.InputTuple,
      CompanyHookSetEvent.OutputTuple,
      CompanyHookSetEvent.OutputObject
    >;
    CompanyHookSet: TypedContractEvent<
      CompanyHookSetEvent.InputTuple,
      CompanyHookSetEvent.OutputTuple,
      CompanyHookSetEvent.OutputObject
    >;

    "CompanyUpgraded(address,address)": TypedContractEvent<
      CompanyUpgradedEvent.InputTuple,
      CompanyUpgradedEvent.OutputTuple,
      CompanyUpgradedEvent.OutputObject
    >;
    CompanyUpgraded: TypedContractEvent<
      CompanyUpgradedEvent.InputTuple,
      CompanyUpgradedEvent.OutputTuple,
      CompanyUpgradedEvent.OutputObject
    >;

    "ExperienceAdded(address,uint256)": TypedContractEvent<
      ExperienceAddedEvent.InputTuple,
      ExperienceAddedEvent.OutputTuple,
      ExperienceAddedEvent.OutputObject
    >;
    ExperienceAdded: TypedContractEvent<
      ExperienceAddedEvent.InputTuple,
      ExperienceAddedEvent.OutputTuple,
      ExperienceAddedEvent.OutputObject
    >;

    "SignerAdded(address)": TypedContractEvent<
      SignerAddedEvent.InputTuple,
      SignerAddedEvent.OutputTuple,
      SignerAddedEvent.OutputObject
    >;
    SignerAdded: TypedContractEvent<
      SignerAddedEvent.InputTuple,
      SignerAddedEvent.OutputTuple,
      SignerAddedEvent.OutputObject
    >;

    "SignerRemoved(address)": TypedContractEvent<
      SignerRemovedEvent.InputTuple,
      SignerRemovedEvent.OutputTuple,
      SignerRemovedEvent.OutputObject
    >;
    SignerRemoved: TypedContractEvent<
      SignerRemovedEvent.InputTuple,
      SignerRemovedEvent.OutputTuple,
      SignerRemovedEvent.OutputObject
    >;
  };
}
