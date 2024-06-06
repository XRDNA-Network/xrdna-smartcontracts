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
  AddressLike,
  ContractRunner,
  ContractMethod,
  Listener,
} from "ethers";
import type {
  TypedContractEvent,
  TypedDeferredTopicFilter,
  TypedEventLog,
  TypedListener,
  TypedContractMethod,
} from "../../common";

export type HookAvatarJumpRequestStruct = {
  avatar: AddressLike;
  destination: AddressLike;
};

export type HookAvatarJumpRequestStructOutput = [
  avatar: string,
  destination: string
] & { avatar: string; destination: string };

export interface IAvatarHookInterface extends Interface {
  getFunction(
    nameOrSignature: "beforeJump" | "onReceiveERC721"
  ): FunctionFragment;

  encodeFunctionData(
    functionFragment: "beforeJump",
    values: [HookAvatarJumpRequestStruct]
  ): string;
  encodeFunctionData(
    functionFragment: "onReceiveERC721",
    values: [AddressLike, AddressLike, BigNumberish]
  ): string;

  decodeFunctionResult(functionFragment: "beforeJump", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "onReceiveERC721",
    data: BytesLike
  ): Result;
}

export interface IAvatarHook extends BaseContract {
  connect(runner?: ContractRunner | null): IAvatarHook;
  waitForDeployment(): Promise<this>;

  interface: IAvatarHookInterface;

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

  beforeJump: TypedContractMethod<
    [request: HookAvatarJumpRequestStruct],
    [boolean],
    "nonpayable"
  >;

  onReceiveERC721: TypedContractMethod<
    [avatar: AddressLike, asset: AddressLike, tokenId: BigNumberish],
    [boolean],
    "nonpayable"
  >;

  getFunction<T extends ContractMethod = ContractMethod>(
    key: string | FunctionFragment
  ): T;

  getFunction(
    nameOrSignature: "beforeJump"
  ): TypedContractMethod<
    [request: HookAvatarJumpRequestStruct],
    [boolean],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "onReceiveERC721"
  ): TypedContractMethod<
    [avatar: AddressLike, asset: AddressLike, tokenId: BigNumberish],
    [boolean],
    "nonpayable"
  >;

  filters: {};
}
