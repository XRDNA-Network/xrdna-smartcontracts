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

export type CompanyRegistryArgsStruct = {
  mainAdmin: AddressLike;
  companyFactory: AddressLike;
  worldRegistry: AddressLike;
  admins: AddressLike[];
};

export type CompanyRegistryArgsStructOutput = [
  mainAdmin: string,
  companyFactory: string,
  worldRegistry: string,
  admins: string[]
] & {
  mainAdmin: string;
  companyFactory: string;
  worldRegistry: string;
  admins: string[];
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

export type CompanyRegistrationRequestStruct = {
  sendTokensToCompanyOwner: boolean;
  owner: AddressLike;
  vector: VectorAddressStruct;
  initData: BytesLike;
  name: string;
};

export type CompanyRegistrationRequestStructOutput = [
  sendTokensToCompanyOwner: boolean,
  owner: string,
  vector: VectorAddressStructOutput,
  initData: string,
  name: string
] & {
  sendTokensToCompanyOwner: boolean;
  owner: string;
  vector: VectorAddressStructOutput;
  initData: string;
  name: string;
};

export interface CompanyRegistryInterface extends Interface {
  getFunction(
    nameOrSignature:
      | "ADMIN_ROLE"
      | "DEFAULT_ADMIN_ROLE"
      | "companyFactory"
      | "currentCompanyVersion"
      | "getRoleAdmin"
      | "grantRole"
      | "hasRole"
      | "isRegisteredCompany"
      | "registerCompany"
      | "renounceRole"
      | "revokeRole"
      | "setCompanyFactory"
      | "setCurrentCompanyVersion"
      | "setWorldRegistry"
      | "supportsInterface"
      | "upgradeCompany"
      | "worldRegistry"
  ): FunctionFragment;

  getEvent(
    nameOrSignatureOrTopic:
      | "CompanyRegistered"
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
    functionFragment: "companyFactory",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "currentCompanyVersion",
    values?: undefined
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
    functionFragment: "isRegisteredCompany",
    values: [AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "registerCompany",
    values: [CompanyRegistrationRequestStruct]
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
    functionFragment: "setCompanyFactory",
    values: [AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "setCurrentCompanyVersion",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "setWorldRegistry",
    values: [AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "supportsInterface",
    values: [BytesLike]
  ): string;
  encodeFunctionData(
    functionFragment: "upgradeCompany",
    values: [BytesLike]
  ): string;
  encodeFunctionData(
    functionFragment: "worldRegistry",
    values?: undefined
  ): string;

  decodeFunctionResult(functionFragment: "ADMIN_ROLE", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "DEFAULT_ADMIN_ROLE",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "companyFactory",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "currentCompanyVersion",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getRoleAdmin",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "grantRole", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "hasRole", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "isRegisteredCompany",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "registerCompany",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "renounceRole",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "revokeRole", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "setCompanyFactory",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "setCurrentCompanyVersion",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "setWorldRegistry",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "supportsInterface",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "upgradeCompany",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "worldRegistry",
    data: BytesLike
  ): Result;
}

export namespace CompanyRegisteredEvent {
  export type InputTuple = [company: AddressLike, arg1: VectorAddressStruct];
  export type OutputTuple = [company: string, arg1: VectorAddressStructOutput];
  export interface OutputObject {
    company: string;
    arg1: VectorAddressStructOutput;
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

export interface CompanyRegistry extends BaseContract {
  connect(runner?: ContractRunner | null): CompanyRegistry;
  waitForDeployment(): Promise<this>;

  interface: CompanyRegistryInterface;

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

  companyFactory: TypedContractMethod<[], [string], "view">;

  currentCompanyVersion: TypedContractMethod<[], [string], "view">;

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

  isRegisteredCompany: TypedContractMethod<
    [company: AddressLike],
    [boolean],
    "view"
  >;

  registerCompany: TypedContractMethod<
    [request: CompanyRegistrationRequestStruct],
    [string],
    "payable"
  >;

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

  setCompanyFactory: TypedContractMethod<
    [factory: AddressLike],
    [void],
    "nonpayable"
  >;

  setCurrentCompanyVersion: TypedContractMethod<
    [version: string],
    [void],
    "nonpayable"
  >;

  setWorldRegistry: TypedContractMethod<
    [registry: AddressLike],
    [void],
    "nonpayable"
  >;

  supportsInterface: TypedContractMethod<
    [interfaceId: BytesLike],
    [boolean],
    "view"
  >;

  upgradeCompany: TypedContractMethod<
    [initData: BytesLike],
    [void],
    "nonpayable"
  >;

  worldRegistry: TypedContractMethod<[], [string], "view">;

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
    nameOrSignature: "companyFactory"
  ): TypedContractMethod<[], [string], "view">;
  getFunction(
    nameOrSignature: "currentCompanyVersion"
  ): TypedContractMethod<[], [string], "view">;
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
    nameOrSignature: "isRegisteredCompany"
  ): TypedContractMethod<[company: AddressLike], [boolean], "view">;
  getFunction(
    nameOrSignature: "registerCompany"
  ): TypedContractMethod<
    [request: CompanyRegistrationRequestStruct],
    [string],
    "payable"
  >;
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
    nameOrSignature: "setCompanyFactory"
  ): TypedContractMethod<[factory: AddressLike], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "setCurrentCompanyVersion"
  ): TypedContractMethod<[version: string], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "setWorldRegistry"
  ): TypedContractMethod<[registry: AddressLike], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "supportsInterface"
  ): TypedContractMethod<[interfaceId: BytesLike], [boolean], "view">;
  getFunction(
    nameOrSignature: "upgradeCompany"
  ): TypedContractMethod<[initData: BytesLike], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "worldRegistry"
  ): TypedContractMethod<[], [string], "view">;

  getEvent(
    key: "CompanyRegistered"
  ): TypedContractEvent<
    CompanyRegisteredEvent.InputTuple,
    CompanyRegisteredEvent.OutputTuple,
    CompanyRegisteredEvent.OutputObject
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
    "CompanyRegistered(address,tuple)": TypedContractEvent<
      CompanyRegisteredEvent.InputTuple,
      CompanyRegisteredEvent.OutputTuple,
      CompanyRegisteredEvent.OutputObject
    >;
    CompanyRegistered: TypedContractEvent<
      CompanyRegisteredEvent.InputTuple,
      CompanyRegisteredEvent.OutputTuple,
      CompanyRegisteredEvent.OutputObject
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