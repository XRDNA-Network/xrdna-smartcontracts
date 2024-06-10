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
} from "../../../common";

export type AddPortalRequestStruct = {
  destination: AddressLike;
  fee: BigNumberish;
};

export type AddPortalRequestStructOutput = [
  destination: string,
  fee: bigint
] & { destination: string; fee: bigint };

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

export type PortalInfoStruct = {
  destination: AddressLike;
  condition: AddressLike;
  fee: BigNumberish;
};

export type PortalInfoStructOutput = [
  destination: string,
  condition: string,
  fee: bigint
] & { destination: string; condition: string; fee: bigint };

export interface PortalRegistryInterface extends Interface {
  getFunction(
    nameOrSignature:
      | "ADMIN_ROLE"
      | "DEFAULT_ADMIN_ROLE"
      | "addCondition"
      | "addPortal"
      | "avatarRegistry"
      | "changePortalFee"
      | "experienceRegistry"
      | "getIdForExperience"
      | "getIdForVectorAddress"
      | "getPortalInfoByAddress"
      | "getPortalInfoById"
      | "getPortalInfoByVectorAddress"
      | "getRoleAdmin"
      | "grantRole"
      | "hasRole"
      | "jumpRequest"
      | "removeCondition"
      | "renounceRole"
      | "revokeRole"
      | "setAvatarRegistry"
      | "setExperienceRegistry"
      | "supportsInterface"
      | "upgradeExperiencePortal"
      | "upgradeRegistry"
      | "upgraded"
  ): FunctionFragment;

  getEvent(
    nameOrSignatureOrTopic:
      | "JumpSuccessful"
      | "PortalAdded"
      | "PortalConditionAdded"
      | "PortalConditionRemoved"
      | "PortalDestinationUpgraded"
      | "PortalFeeChanged"
      | "PortalRegistryUpgraded"
      | "RoleAdminChanged"
      | "RoleGranted"
      | "RoleRevoked"
  ): EventFragment;

  encodeFunctionData(
    functionFragment: "ADMIN_ROLE",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "DEFAULT_ADMIN_ROLE",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "addCondition",
    values: [AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "addPortal",
    values: [AddPortalRequestStruct]
  ): string;
  encodeFunctionData(
    functionFragment: "avatarRegistry",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "changePortalFee",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "experienceRegistry",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "getIdForExperience",
    values: [AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "getIdForVectorAddress",
    values: [VectorAddressStruct]
  ): string;
  encodeFunctionData(
    functionFragment: "getPortalInfoByAddress",
    values: [AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "getPortalInfoById",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "getPortalInfoByVectorAddress",
    values: [VectorAddressStruct]
  ): string;
  encodeFunctionData(
    functionFragment: "getRoleAdmin",
    values: [BytesLike]
  ): string;
  encodeFunctionData(
    functionFragment: "grantRole",
    values: [BytesLike, AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "hasRole",
    values: [BytesLike, AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "jumpRequest",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "removeCondition",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "renounceRole",
    values: [BytesLike, AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "revokeRole",
    values: [BytesLike, AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "setAvatarRegistry",
    values: [AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "setExperienceRegistry",
    values: [AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "supportsInterface",
    values: [BytesLike]
  ): string;
  encodeFunctionData(
    functionFragment: "upgradeExperiencePortal",
    values: [AddressLike, AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "upgradeRegistry",
    values: [AddressLike]
  ): string;
  encodeFunctionData(functionFragment: "upgraded", values?: undefined): string;

  decodeFunctionResult(functionFragment: "ADMIN_ROLE", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "DEFAULT_ADMIN_ROLE",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "addCondition",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "addPortal", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "avatarRegistry",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "changePortalFee",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "experienceRegistry",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getIdForExperience",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getIdForVectorAddress",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getPortalInfoByAddress",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getPortalInfoById",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getPortalInfoByVectorAddress",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getRoleAdmin",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "grantRole", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "hasRole", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "jumpRequest",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "removeCondition",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "renounceRole",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "revokeRole", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "setAvatarRegistry",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "setExperienceRegistry",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "supportsInterface",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "upgradeExperiencePortal",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "upgradeRegistry",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "upgraded", data: BytesLike): Result;
}

export namespace JumpSuccessfulEvent {
  export type InputTuple = [
    portalId: BigNumberish,
    avatar: AddressLike,
    destination: AddressLike
  ];
  export type OutputTuple = [
    portalId: bigint,
    avatar: string,
    destination: string
  ];
  export interface OutputObject {
    portalId: bigint;
    avatar: string;
    destination: string;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export namespace PortalAddedEvent {
  export type InputTuple = [portalId: BigNumberish, experience: AddressLike];
  export type OutputTuple = [portalId: bigint, experience: string];
  export interface OutputObject {
    portalId: bigint;
    experience: string;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export namespace PortalConditionAddedEvent {
  export type InputTuple = [portalId: BigNumberish, condition: AddressLike];
  export type OutputTuple = [portalId: bigint, condition: string];
  export interface OutputObject {
    portalId: bigint;
    condition: string;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export namespace PortalConditionRemovedEvent {
  export type InputTuple = [portalId: BigNumberish];
  export type OutputTuple = [portalId: bigint];
  export interface OutputObject {
    portalId: bigint;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export namespace PortalDestinationUpgradedEvent {
  export type InputTuple = [
    portalId: BigNumberish,
    oldExperience: AddressLike,
    newExperience: AddressLike
  ];
  export type OutputTuple = [
    portalId: bigint,
    oldExperience: string,
    newExperience: string
  ];
  export interface OutputObject {
    portalId: bigint;
    oldExperience: string;
    newExperience: string;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export namespace PortalFeeChangedEvent {
  export type InputTuple = [portalId: BigNumberish, newFee: BigNumberish];
  export type OutputTuple = [portalId: bigint, newFee: bigint];
  export interface OutputObject {
    portalId: bigint;
    newFee: bigint;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export namespace PortalRegistryUpgradedEvent {
  export type InputTuple = [newRegistry: AddressLike];
  export type OutputTuple = [newRegistry: string];
  export interface OutputObject {
    newRegistry: string;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export namespace RoleAdminChangedEvent {
  export type InputTuple = [
    role: BytesLike,
    previousAdminRole: BytesLike,
    newAdminRole: BytesLike
  ];
  export type OutputTuple = [
    role: string,
    previousAdminRole: string,
    newAdminRole: string
  ];
  export interface OutputObject {
    role: string;
    previousAdminRole: string;
    newAdminRole: string;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export namespace RoleGrantedEvent {
  export type InputTuple = [
    role: BytesLike,
    account: AddressLike,
    sender: AddressLike
  ];
  export type OutputTuple = [role: string, account: string, sender: string];
  export interface OutputObject {
    role: string;
    account: string;
    sender: string;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export namespace RoleRevokedEvent {
  export type InputTuple = [
    role: BytesLike,
    account: AddressLike,
    sender: AddressLike
  ];
  export type OutputTuple = [role: string, account: string, sender: string];
  export interface OutputObject {
    role: string;
    account: string;
    sender: string;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export interface PortalRegistry extends BaseContract {
  connect(runner?: ContractRunner | null): PortalRegistry;
  waitForDeployment(): Promise<this>;

  interface: PortalRegistryInterface;

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

  ADMIN_ROLE: TypedContractMethod<[], [string], "view">;

  DEFAULT_ADMIN_ROLE: TypedContractMethod<[], [string], "view">;

  addCondition: TypedContractMethod<
    [condition: AddressLike],
    [void],
    "nonpayable"
  >;

  addPortal: TypedContractMethod<
    [req: AddPortalRequestStruct],
    [bigint],
    "nonpayable"
  >;

  avatarRegistry: TypedContractMethod<[], [string], "view">;

  changePortalFee: TypedContractMethod<
    [newFee: BigNumberish],
    [void],
    "nonpayable"
  >;

  experienceRegistry: TypedContractMethod<[], [string], "view">;

  getIdForExperience: TypedContractMethod<
    [experience: AddressLike],
    [bigint],
    "view"
  >;

  getIdForVectorAddress: TypedContractMethod<
    [va: VectorAddressStruct],
    [bigint],
    "view"
  >;

  getPortalInfoByAddress: TypedContractMethod<
    [experience: AddressLike],
    [PortalInfoStructOutput],
    "view"
  >;

  getPortalInfoById: TypedContractMethod<
    [portalId: BigNumberish],
    [PortalInfoStructOutput],
    "view"
  >;

  getPortalInfoByVectorAddress: TypedContractMethod<
    [va: VectorAddressStruct],
    [PortalInfoStructOutput],
    "view"
  >;

  getRoleAdmin: TypedContractMethod<[role: BytesLike], [string], "view">;

  grantRole: TypedContractMethod<
    [role: BytesLike, account: AddressLike],
    [void],
    "nonpayable"
  >;

  hasRole: TypedContractMethod<
    [role: BytesLike, account: AddressLike],
    [boolean],
    "view"
  >;

  jumpRequest: TypedContractMethod<
    [portalId: BigNumberish],
    [string],
    "payable"
  >;

  removeCondition: TypedContractMethod<[], [void], "nonpayable">;

  renounceRole: TypedContractMethod<
    [role: BytesLike, callerConfirmation: AddressLike],
    [void],
    "nonpayable"
  >;

  revokeRole: TypedContractMethod<
    [role: BytesLike, account: AddressLike],
    [void],
    "nonpayable"
  >;

  setAvatarRegistry: TypedContractMethod<
    [registry: AddressLike],
    [void],
    "nonpayable"
  >;

  setExperienceRegistry: TypedContractMethod<
    [registry: AddressLike],
    [void],
    "nonpayable"
  >;

  supportsInterface: TypedContractMethod<
    [interfaceId: BytesLike],
    [boolean],
    "view"
  >;

  upgradeExperiencePortal: TypedContractMethod<
    [oldExperience: AddressLike, newExperience: AddressLike],
    [void],
    "nonpayable"
  >;

  upgradeRegistry: TypedContractMethod<
    [newRegistry: AddressLike],
    [void],
    "nonpayable"
  >;

  upgraded: TypedContractMethod<[], [boolean], "view">;

  getFunction<T extends ContractMethod = ContractMethod>(
    key: string | FunctionFragment
  ): T;

  getFunction(
    nameOrSignature: "ADMIN_ROLE"
  ): TypedContractMethod<[], [string], "view">;
  getFunction(
    nameOrSignature: "DEFAULT_ADMIN_ROLE"
  ): TypedContractMethod<[], [string], "view">;
  getFunction(
    nameOrSignature: "addCondition"
  ): TypedContractMethod<[condition: AddressLike], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "addPortal"
  ): TypedContractMethod<[req: AddPortalRequestStruct], [bigint], "nonpayable">;
  getFunction(
    nameOrSignature: "avatarRegistry"
  ): TypedContractMethod<[], [string], "view">;
  getFunction(
    nameOrSignature: "changePortalFee"
  ): TypedContractMethod<[newFee: BigNumberish], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "experienceRegistry"
  ): TypedContractMethod<[], [string], "view">;
  getFunction(
    nameOrSignature: "getIdForExperience"
  ): TypedContractMethod<[experience: AddressLike], [bigint], "view">;
  getFunction(
    nameOrSignature: "getIdForVectorAddress"
  ): TypedContractMethod<[va: VectorAddressStruct], [bigint], "view">;
  getFunction(
    nameOrSignature: "getPortalInfoByAddress"
  ): TypedContractMethod<
    [experience: AddressLike],
    [PortalInfoStructOutput],
    "view"
  >;
  getFunction(
    nameOrSignature: "getPortalInfoById"
  ): TypedContractMethod<
    [portalId: BigNumberish],
    [PortalInfoStructOutput],
    "view"
  >;
  getFunction(
    nameOrSignature: "getPortalInfoByVectorAddress"
  ): TypedContractMethod<
    [va: VectorAddressStruct],
    [PortalInfoStructOutput],
    "view"
  >;
  getFunction(
    nameOrSignature: "getRoleAdmin"
  ): TypedContractMethod<[role: BytesLike], [string], "view">;
  getFunction(
    nameOrSignature: "grantRole"
  ): TypedContractMethod<
    [role: BytesLike, account: AddressLike],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "hasRole"
  ): TypedContractMethod<
    [role: BytesLike, account: AddressLike],
    [boolean],
    "view"
  >;
  getFunction(
    nameOrSignature: "jumpRequest"
  ): TypedContractMethod<[portalId: BigNumberish], [string], "payable">;
  getFunction(
    nameOrSignature: "removeCondition"
  ): TypedContractMethod<[], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "renounceRole"
  ): TypedContractMethod<
    [role: BytesLike, callerConfirmation: AddressLike],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "revokeRole"
  ): TypedContractMethod<
    [role: BytesLike, account: AddressLike],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "setAvatarRegistry"
  ): TypedContractMethod<[registry: AddressLike], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "setExperienceRegistry"
  ): TypedContractMethod<[registry: AddressLike], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "supportsInterface"
  ): TypedContractMethod<[interfaceId: BytesLike], [boolean], "view">;
  getFunction(
    nameOrSignature: "upgradeExperiencePortal"
  ): TypedContractMethod<
    [oldExperience: AddressLike, newExperience: AddressLike],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "upgradeRegistry"
  ): TypedContractMethod<[newRegistry: AddressLike], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "upgraded"
  ): TypedContractMethod<[], [boolean], "view">;

  getEvent(
    key: "JumpSuccessful"
  ): TypedContractEvent<
    JumpSuccessfulEvent.InputTuple,
    JumpSuccessfulEvent.OutputTuple,
    JumpSuccessfulEvent.OutputObject
  >;
  getEvent(
    key: "PortalAdded"
  ): TypedContractEvent<
    PortalAddedEvent.InputTuple,
    PortalAddedEvent.OutputTuple,
    PortalAddedEvent.OutputObject
  >;
  getEvent(
    key: "PortalConditionAdded"
  ): TypedContractEvent<
    PortalConditionAddedEvent.InputTuple,
    PortalConditionAddedEvent.OutputTuple,
    PortalConditionAddedEvent.OutputObject
  >;
  getEvent(
    key: "PortalConditionRemoved"
  ): TypedContractEvent<
    PortalConditionRemovedEvent.InputTuple,
    PortalConditionRemovedEvent.OutputTuple,
    PortalConditionRemovedEvent.OutputObject
  >;
  getEvent(
    key: "PortalDestinationUpgraded"
  ): TypedContractEvent<
    PortalDestinationUpgradedEvent.InputTuple,
    PortalDestinationUpgradedEvent.OutputTuple,
    PortalDestinationUpgradedEvent.OutputObject
  >;
  getEvent(
    key: "PortalFeeChanged"
  ): TypedContractEvent<
    PortalFeeChangedEvent.InputTuple,
    PortalFeeChangedEvent.OutputTuple,
    PortalFeeChangedEvent.OutputObject
  >;
  getEvent(
    key: "PortalRegistryUpgraded"
  ): TypedContractEvent<
    PortalRegistryUpgradedEvent.InputTuple,
    PortalRegistryUpgradedEvent.OutputTuple,
    PortalRegistryUpgradedEvent.OutputObject
  >;
  getEvent(
    key: "RoleAdminChanged"
  ): TypedContractEvent<
    RoleAdminChangedEvent.InputTuple,
    RoleAdminChangedEvent.OutputTuple,
    RoleAdminChangedEvent.OutputObject
  >;
  getEvent(
    key: "RoleGranted"
  ): TypedContractEvent<
    RoleGrantedEvent.InputTuple,
    RoleGrantedEvent.OutputTuple,
    RoleGrantedEvent.OutputObject
  >;
  getEvent(
    key: "RoleRevoked"
  ): TypedContractEvent<
    RoleRevokedEvent.InputTuple,
    RoleRevokedEvent.OutputTuple,
    RoleRevokedEvent.OutputObject
  >;

  filters: {
    "JumpSuccessful(uint256,address,address)": TypedContractEvent<
      JumpSuccessfulEvent.InputTuple,
      JumpSuccessfulEvent.OutputTuple,
      JumpSuccessfulEvent.OutputObject
    >;
    JumpSuccessful: TypedContractEvent<
      JumpSuccessfulEvent.InputTuple,
      JumpSuccessfulEvent.OutputTuple,
      JumpSuccessfulEvent.OutputObject
    >;

    "PortalAdded(uint256,address)": TypedContractEvent<
      PortalAddedEvent.InputTuple,
      PortalAddedEvent.OutputTuple,
      PortalAddedEvent.OutputObject
    >;
    PortalAdded: TypedContractEvent<
      PortalAddedEvent.InputTuple,
      PortalAddedEvent.OutputTuple,
      PortalAddedEvent.OutputObject
    >;

    "PortalConditionAdded(uint256,address)": TypedContractEvent<
      PortalConditionAddedEvent.InputTuple,
      PortalConditionAddedEvent.OutputTuple,
      PortalConditionAddedEvent.OutputObject
    >;
    PortalConditionAdded: TypedContractEvent<
      PortalConditionAddedEvent.InputTuple,
      PortalConditionAddedEvent.OutputTuple,
      PortalConditionAddedEvent.OutputObject
    >;

    "PortalConditionRemoved(uint256)": TypedContractEvent<
      PortalConditionRemovedEvent.InputTuple,
      PortalConditionRemovedEvent.OutputTuple,
      PortalConditionRemovedEvent.OutputObject
    >;
    PortalConditionRemoved: TypedContractEvent<
      PortalConditionRemovedEvent.InputTuple,
      PortalConditionRemovedEvent.OutputTuple,
      PortalConditionRemovedEvent.OutputObject
    >;

    "PortalDestinationUpgraded(uint256,address,address)": TypedContractEvent<
      PortalDestinationUpgradedEvent.InputTuple,
      PortalDestinationUpgradedEvent.OutputTuple,
      PortalDestinationUpgradedEvent.OutputObject
    >;
    PortalDestinationUpgraded: TypedContractEvent<
      PortalDestinationUpgradedEvent.InputTuple,
      PortalDestinationUpgradedEvent.OutputTuple,
      PortalDestinationUpgradedEvent.OutputObject
    >;

    "PortalFeeChanged(uint256,uint256)": TypedContractEvent<
      PortalFeeChangedEvent.InputTuple,
      PortalFeeChangedEvent.OutputTuple,
      PortalFeeChangedEvent.OutputObject
    >;
    PortalFeeChanged: TypedContractEvent<
      PortalFeeChangedEvent.InputTuple,
      PortalFeeChangedEvent.OutputTuple,
      PortalFeeChangedEvent.OutputObject
    >;

    "PortalRegistryUpgraded(address)": TypedContractEvent<
      PortalRegistryUpgradedEvent.InputTuple,
      PortalRegistryUpgradedEvent.OutputTuple,
      PortalRegistryUpgradedEvent.OutputObject
    >;
    PortalRegistryUpgraded: TypedContractEvent<
      PortalRegistryUpgradedEvent.InputTuple,
      PortalRegistryUpgradedEvent.OutputTuple,
      PortalRegistryUpgradedEvent.OutputObject
    >;

    "RoleAdminChanged(bytes32,bytes32,bytes32)": TypedContractEvent<
      RoleAdminChangedEvent.InputTuple,
      RoleAdminChangedEvent.OutputTuple,
      RoleAdminChangedEvent.OutputObject
    >;
    RoleAdminChanged: TypedContractEvent<
      RoleAdminChangedEvent.InputTuple,
      RoleAdminChangedEvent.OutputTuple,
      RoleAdminChangedEvent.OutputObject
    >;

    "RoleGranted(bytes32,address,address)": TypedContractEvent<
      RoleGrantedEvent.InputTuple,
      RoleGrantedEvent.OutputTuple,
      RoleGrantedEvent.OutputObject
    >;
    RoleGranted: TypedContractEvent<
      RoleGrantedEvent.InputTuple,
      RoleGrantedEvent.OutputTuple,
      RoleGrantedEvent.OutputObject
    >;

    "RoleRevoked(bytes32,address,address)": TypedContractEvent<
      RoleRevokedEvent.InputTuple,
      RoleRevokedEvent.OutputTuple,
      RoleRevokedEvent.OutputObject
    >;
    RoleRevoked: TypedContractEvent<
      RoleRevokedEvent.InputTuple,
      RoleRevokedEvent.OutputTuple,
      RoleRevokedEvent.OutputObject
    >;
  };
}