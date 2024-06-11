/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import {
  Contract,
  ContractFactory,
  ContractTransactionResponse,
  Interface,
} from "ethers";
import type { Signer, ContractDeployTransaction, ContractRunner } from "ethers";
import type { NonPayableOverrides } from "../../../common";
import type {
  AvatarProxy,
  AvatarProxyInterface,
  BaseProxyConstructorArgsStruct,
} from "../../../contracts/avatar/AvatarProxy";

const _abi = [
  {
    inputs: [
      {
        components: [
          {
            internalType: "address",
            name: "factory",
            type: "address",
          },
          {
            internalType: "address",
            name: "registry",
            type: "address",
          },
        ],
        internalType: "struct BaseProxyConstructorArgs",
        name: "args",
        type: "tuple",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "implementation",
        type: "address",
      },
    ],
    name: "ImplementationChanged",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "sender",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "value",
        type: "uint256",
      },
    ],
    name: "ReceivedFunds",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "signer",
        type: "address",
      },
    ],
    name: "SignerAdded",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "signer",
        type: "address",
      },
    ],
    name: "SignerRemoved",
    type: "event",
  },
  {
    stateMutability: "payable",
    type: "fallback",
  },
  {
    inputs: [
      {
        internalType: "address[]",
        name: "signers",
        type: "address[]",
      },
    ],
    name: "addSigners",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "factory",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getImplementation",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_implementation",
        type: "address",
      },
    ],
    name: "initProxy",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "signer",
        type: "address",
      },
    ],
    name: "isSigner",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "registry",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address[]",
        name: "signers",
        type: "address[]",
      },
    ],
    name: "removeSigners",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "impl",
        type: "address",
      },
    ],
    name: "setImplementation",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    stateMutability: "payable",
    type: "receive",
  },
] as const;

const _bytecode =
  "0x60c060405234801561001057600080fd5b50604051610bc6380380610bc683398101604081905261002f9161013a565b805181906001600160a01b03166100985760405162461bcd60e51b815260206004820152602260248201527f4261736550726f78793a20666163746f7279206973207a65726f206164647265604482015261737360f01b60648201526084015b60405180910390fd5b60208101516001600160a01b03166100fe5760405162461bcd60e51b815260206004820152602360248201527f4261736550726f78793a207265676973747279206973207a65726f206164647260448201526265737360e81b606482015260840161008f565b80516001600160a01b039081166080526020909101511660a052506101a2565b80516001600160a01b038116811461013557600080fd5b919050565b60006040828403121561014c57600080fd5b604080519081016001600160401b038111828210171561017c57634e487b7160e01b600052604160045260246000fd5b6040526101888361011e565b81526101966020840161011e565b60208201529392505050565b60805160a0516109f16101d56000396000818161016a01526104d3015260008181610256015261036b01526109f16000f3fe60806040526004361061007f5760003560e01c8063aaf10f421161004e578063aaf10f4214610219578063c45a015514610244578063d784d42614610278578063e8906a2d14610298576100bc565b80637b103999146101585780637df73e27146101a95780638d361e43146101d95780639c020061146101f9576100bc565b366100bc5760405134815233907f5741979df5f3e491501da74d3b0a83dd2496ab1f34929865b3e190a8ad75859a9060200160405180910390a25b005b60008051602061099c83398151915280546001600160a01b0316806101335760405162461bcd60e51b815260206004820152602260248201527f576f726c6450726f78793a20696d706c656d656e746174696f6e206e6f742073604482015261195d60f21b60648201526084015b60405180910390fd5b60405136600082376000803683855af43d806000843e818015610154578184f35b8184fd5b34801561016457600080fd5b5061018c7f000000000000000000000000000000000000000000000000000000000000000081565b6040516001600160a01b0390911681526020015b60405180910390f35b3480156101b557600080fd5b506101c96101c436600461089c565b6102b8565b60405190151581526020016101a0565b3480156101e557600080fd5b506100ba6101f43660046108c5565b6102fb565b34801561020557600080fd5b506100ba61021436600461089c565b610360565b34801561022557600080fd5b5060008051602061099c833981519152546001600160a01b031661018c565b34801561025057600080fd5b5061018c7f000000000000000000000000000000000000000000000000000000000000000081565b34801561028457600080fd5b506100ba61029336600461089c565b6104c8565b3480156102a457600080fd5b506100ba6102b33660046108c5565b6105a1565b600060008051602061099c8339815191526102f4817fe2f4eaae4a9751e85a3e4a7b9587827a877f29914755229b07a7b2da98285f7085610601565b9392505050565b60008051602061099c833981519152610335817fa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c2177533610601565b6103515760405162461bcd60e51b815260040161012a9061093a565b61035b838361062e565b505050565b336001600160a01b037f000000000000000000000000000000000000000000000000000000000000000016146103d85760405162461bcd60e51b815260206004820181905260248201527f4261736550726f78793a2063616c6c6572206973206e6f7420666163746f7279604482015260640161012a565b6001600160a01b0381166104415760405162461bcd60e51b815260206004820152602a60248201527f576f726c6450726f78793a20696d706c656d656e746174696f6e206973207a65604482015269726f206164647265737360b01b606482015260840161012a565b60008051602061099c83398151915280546001600160a01b0316156104a85760405162461bcd60e51b815260206004820152601f60248201527f576f726c6450726f78793a20616c726561647920696e697469616c697a656400604482015260640161012a565b80546001600160a01b0319166001600160a01b0392909216919091179055565b336001600160a01b037f0000000000000000000000000000000000000000000000000000000000000000161461054a5760405162461bcd60e51b815260206004820152602160248201527f4261736550726f78793a2063616c6c6572206973206e6f7420726567697374726044820152607960f81b606482015260840161012a565b60008051602061099c83398151915280546001600160a01b0319166001600160a01b03831690811782556040517f2989b377844ae55f0ca303ad21490d8519f8cf871ad6b5ba3dbec736bb54c63f90600090a25050565b60008051602061099c8339815191526105db817fa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c2177533610601565b6105f75760405162461bcd60e51b815260040161012a9061093a565b61035b8383610707565b6000918252600192909201602090815260408083206001600160a01b039094168352929052205460ff1690565b60008051602061099c83398151915260005b828110156107015761069d7fe2f4eaae4a9751e85a3e4a7b9587827a877f29914755229b07a7b2da98285f7085858481811061067e5761067e610985565b9050602002016020810190610693919061089c565b8491906000610863565b8383828181106106af576106af610985565b90506020020160208101906106c4919061089c565b6001600160a01b03167f3525e22824a8a7df2c9a6029941c824cf95b6447f1e13d5128fd3826d35afe8b60405160405180910390a2600101610640565b50505050565b60008051602061099c83398151915260005b8281101561070157600084848381811061073557610735610985565b905060200201602081019061074a919061089c565b6001600160a01b0316036107aa5760405162461bcd60e51b815260206004820152602160248201527f4261736550726f78793a207369676e6572206973207a65726f206164647265736044820152607360f81b606482015260840161012a565b6107ff7fe2f4eaae4a9751e85a3e4a7b9587827a877f29914755229b07a7b2da98285f708585848181106107e0576107e0610985565b90506020020160208101906107f5919061089c565b8491906001610863565b83838281811061081157610811610985565b9050602002016020810190610826919061089c565b6001600160a01b03167f47d1c22a25bb3a5d4e481b9b1e6944c2eade3181a0a20b495ed61d35b5323f2460405160405180910390a2600101610719565b60009283526001909301602090815260408084206001600160a01b0390931684529190529020805491151560ff19909216919091179055565b6000602082840312156108ae57600080fd5b81356001600160a01b03811681146102f457600080fd5b600080602083850312156108d857600080fd5b823567ffffffffffffffff808211156108f057600080fd5b818501915085601f83011261090457600080fd5b81358181111561091357600080fd5b8660208260051b850101111561092857600080fd5b60209290920196919550909350505050565b6020808252602b908201527f426173654163636573733a2063616c6c657220646f6573206e6f74206861766560408201526a2061646d696e20726f6c6560a81b606082015260800190565b634e487b7160e01b600052603260045260246000fdfe1f07e7b49187e1cf67924ca1fa35732211c5bb2c23b6b53ee47453438de7285ea26469706673582212200c26328afe411ca3047fc83ea21356d10ecd7dff79f837554641ba3dd20847ca64736f6c63430008180033";

type AvatarProxyConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: AvatarProxyConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class AvatarProxy__factory extends ContractFactory {
  constructor(...args: AvatarProxyConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override getDeployTransaction(
    args: BaseProxyConstructorArgsStruct,
    overrides?: NonPayableOverrides & { from?: string }
  ): Promise<ContractDeployTransaction> {
    return super.getDeployTransaction(args, overrides || {});
  }
  override deploy(
    args: BaseProxyConstructorArgsStruct,
    overrides?: NonPayableOverrides & { from?: string }
  ) {
    return super.deploy(args, overrides || {}) as Promise<
      AvatarProxy & {
        deploymentTransaction(): ContractTransactionResponse;
      }
    >;
  }
  override connect(runner: ContractRunner | null): AvatarProxy__factory {
    return super.connect(runner) as AvatarProxy__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): AvatarProxyInterface {
    return new Interface(_abi) as AvatarProxyInterface;
  }
  static connect(address: string, runner?: ContractRunner | null): AvatarProxy {
    return new Contract(address, _abi, runner) as unknown as AvatarProxy;
  }
}
