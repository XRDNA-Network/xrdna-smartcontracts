/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import type {
  BaseContract,
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

export interface IExperienceHookInterface extends Interface {
  getFunction(nameOrSignature: "beforeJumpEntry"): FunctionFragment;

  encodeFunctionData(
    functionFragment: "beforeJumpEntry",
    values: [AddressLike, AddressLike, AddressLike, AddressLike]
  ): string;

  decodeFunctionResult(
    functionFragment: "beforeJumpEntry",
    data: BytesLike
  ): Result;
}

export interface IExperienceHook extends BaseContract {
  connect(runner?: ContractRunner | null): IExperienceHook;
  waitForDeployment(): Promise<this>;

  interface: IExperienceHookInterface;

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

  beforeJumpEntry: TypedContractMethod<
    [
      destExperience: AddressLike,
      sourceWorld: AddressLike,
      sourceCompany: AddressLike,
      avatar: AddressLike
    ],
    [boolean],
    "nonpayable"
  >;

  getFunction<T extends ContractMethod = ContractMethod>(
    key: string | FunctionFragment
  ): T;

  getFunction(
    nameOrSignature: "beforeJumpEntry"
  ): TypedContractMethod<
    [
      destExperience: AddressLike,
      sourceWorld: AddressLike,
      sourceCompany: AddressLike,
      avatar: AddressLike
    ],
    [boolean],
    "nonpayable"
  >;

  filters: {};
}