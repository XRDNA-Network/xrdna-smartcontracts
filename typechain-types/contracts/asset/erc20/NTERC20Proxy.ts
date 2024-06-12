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

export type BaseProxyConstructorArgsStruct = {
  factory: AddressLike;
  registry: AddressLike;
};

export type BaseProxyConstructorArgsStructOutput = [
  factory: string,
  registry: string
] & { factory: string; registry: string };

export interface NTERC20ProxyInterface extends Interface {
  getFunction(
    nameOrSignature:
      | "addSigners"
      | "factory"
      | "getImplementation"
      | "initProxy"
      | "isSigner"
      | "registry"
      | "removeSigners"
  ): FunctionFragment;

  getEvent(
    nameOrSignatureOrTopic:
      | "ImplementationChanged"
      | "ReceivedFunds"
      | "SignerAdded"
      | "SignerRemoved"
  ): EventFragment;

  encodeFunctionData(
    functionFragment: "addSigners",
    values: [AddressLike[]]
  ): string;
  encodeFunctionData(functionFragment: "factory", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "getImplementation",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "initProxy",
    values: [AddressLike]
  ): string;
  encodeFunctionData(
    functionFragment: "isSigner",
    values: [AddressLike]
  ): string;
  encodeFunctionData(functionFragment: "registry", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "removeSigners",
    values: [AddressLike[]]
  ): string;

  decodeFunctionResult(functionFragment: "addSigners", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "factory", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "getImplementation",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "initProxy", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "isSigner", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "registry", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "removeSigners",
    data: BytesLike
  ): Result;
}

export namespace ImplementationChangedEvent {
  export type InputTuple = [implementation: AddressLike];
  export type OutputTuple = [implementation: string];
  export interface OutputObject {
    implementation: string;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export namespace ReceivedFundsEvent {
  export type InputTuple = [sender: AddressLike, value: BigNumberish];
  export type OutputTuple = [sender: string, value: bigint];
  export interface OutputObject {
    sender: string;
    value: bigint;
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

export interface NTERC20Proxy extends BaseContract {
  connect(runner?: ContractRunner | null): NTERC20Proxy;
  waitForDeployment(): Promise<this>;

  interface: NTERC20ProxyInterface;

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

  addSigners: TypedContractMethod<
    [signers: AddressLike[]],
    [void],
    "nonpayable"
  >;

  factory: TypedContractMethod<[], [string], "view">;

  getImplementation: TypedContractMethod<[], [string], "view">;

  initProxy: TypedContractMethod<
    [_implementation: AddressLike],
    [void],
    "nonpayable"
  >;

  isSigner: TypedContractMethod<[signer: AddressLike], [boolean], "view">;

  registry: TypedContractMethod<[], [string], "view">;

  removeSigners: TypedContractMethod<
    [signers: AddressLike[]],
    [void],
    "nonpayable"
  >;

  getFunction<T extends ContractMethod = ContractMethod>(
    key: string | FunctionFragment
  ): T;

  getFunction(
    nameOrSignature: "addSigners"
  ): TypedContractMethod<[signers: AddressLike[]], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "factory"
  ): TypedContractMethod<[], [string], "view">;
  getFunction(
    nameOrSignature: "getImplementation"
  ): TypedContractMethod<[], [string], "view">;
  getFunction(
    nameOrSignature: "initProxy"
  ): TypedContractMethod<[_implementation: AddressLike], [void], "nonpayable">;
  getFunction(
    nameOrSignature: "isSigner"
  ): TypedContractMethod<[signer: AddressLike], [boolean], "view">;
  getFunction(
    nameOrSignature: "registry"
  ): TypedContractMethod<[], [string], "view">;
  getFunction(
    nameOrSignature: "removeSigners"
  ): TypedContractMethod<[signers: AddressLike[]], [void], "nonpayable">;

  getEvent(
    key: "ImplementationChanged"
  ): TypedContractEvent<
    ImplementationChangedEvent.InputTuple,
    ImplementationChangedEvent.OutputTuple,
    ImplementationChangedEvent.OutputObject
  >;
  getEvent(
    key: "ReceivedFunds"
  ): TypedContractEvent<
    ReceivedFundsEvent.InputTuple,
    ReceivedFundsEvent.OutputTuple,
    ReceivedFundsEvent.OutputObject
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
    "ImplementationChanged(address)": TypedContractEvent<
      ImplementationChangedEvent.InputTuple,
      ImplementationChangedEvent.OutputTuple,
      ImplementationChangedEvent.OutputObject
    >;
    ImplementationChanged: TypedContractEvent<
      ImplementationChangedEvent.InputTuple,
      ImplementationChangedEvent.OutputTuple,
      ImplementationChangedEvent.OutputObject
    >;

    "ReceivedFunds(address,uint256)": TypedContractEvent<
      ReceivedFundsEvent.InputTuple,
      ReceivedFundsEvent.OutputTuple,
      ReceivedFundsEvent.OutputObject
    >;
    ReceivedFunds: TypedContractEvent<
      ReceivedFundsEvent.InputTuple,
      ReceivedFundsEvent.OutputTuple,
      ReceivedFundsEvent.OutputObject
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