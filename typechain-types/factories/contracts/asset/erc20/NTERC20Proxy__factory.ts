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
import type { NonPayableOverrides } from "../../../../common";
import type {
  NTERC20Proxy,
  NTERC20ProxyInterface,
  BaseProxyConstructorArgsStruct,
} from "../../../../contracts/asset/erc20/NTERC20Proxy";

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
    stateMutability: "payable",
    type: "receive",
  },
] as const;

const _bytecode =
  "0x60c060405234801561001057600080fd5b50604051610ad0380380610ad083398101604081905261002f9161013a565b805181906001600160a01b03166100985760405162461bcd60e51b815260206004820152602260248201527f4261736550726f78793a20666163746f7279206973207a65726f206164647265604482015261737360f01b60648201526084015b60405180910390fd5b60208101516001600160a01b03166100fe5760405162461bcd60e51b815260206004820152602360248201527f4261736550726f78793a207265676973747279206973207a65726f206164647260448201526265737360e81b606482015260840161008f565b80516001600160a01b039081166080526020909101511660a052506101a2565b80516001600160a01b038116811461013557600080fd5b919050565b60006040828403121561014c57600080fd5b604080519081016001600160401b038111828210171561017c57634e487b7160e01b600052604160045260246000fd5b6040526101888361011e565b81526101966020840161011e565b60208201529392505050565b60805160a0516109026101ce600039600061015f01526000818161024b015261034001526109026000f3fe6080604052600436106100745760003560e01c80639c0200611161004e5780639c020061146101ee578063aaf10f421461020e578063c45a015514610239578063e8906a2d1461026d576100b1565b80637b1039991461014d5780637df73e271461019e5780638d361e43146101ce576100b1565b366100b15760405134815233907f5741979df5f3e491501da74d3b0a83dd2496ab1f34929865b3e190a8ad75859a9060200160405180910390a25b005b6000805160206108ad83398151915280546001600160a01b0316806101285760405162461bcd60e51b815260206004820152602260248201527f576f726c6450726f78793a20696d706c656d656e746174696f6e206e6f742073604482015261195d60f21b60648201526084015b60405180910390fd5b60405136600082376000803683855af43d806000843e818015610149578184f35b8184fd5b34801561015957600080fd5b506101817f000000000000000000000000000000000000000000000000000000000000000081565b6040516001600160a01b0390911681526020015b60405180910390f35b3480156101aa57600080fd5b506101be6101b93660046107ad565b61028d565b6040519015158152602001610195565b3480156101da57600080fd5b506100af6101e93660046107d6565b6102d0565b3480156101fa57600080fd5b506100af6102093660046107ad565b610335565b34801561021a57600080fd5b506000805160206108ad833981519152546001600160a01b0316610181565b34801561024557600080fd5b506101817f000000000000000000000000000000000000000000000000000000000000000081565b34801561027957600080fd5b506100af6102883660046107d6565b61049d565b60006000805160206108ad8339815191526102c9817fe2f4eaae4a9751e85a3e4a7b9587827a877f29914755229b07a7b2da98285f70856104fd565b9392505050565b6000805160206108ad83398151915261030a817fa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775336104fd565b6103265760405162461bcd60e51b815260040161011f9061084b565b610330838361052a565b505050565b336001600160a01b037f000000000000000000000000000000000000000000000000000000000000000016146103ad5760405162461bcd60e51b815260206004820181905260248201527f4261736550726f78793a2063616c6c6572206973206e6f7420666163746f7279604482015260640161011f565b6001600160a01b0381166104165760405162461bcd60e51b815260206004820152602a60248201527f576f726c6450726f78793a20696d706c656d656e746174696f6e206973207a65604482015269726f206164647265737360b01b606482015260840161011f565b6000805160206108ad83398151915280546001600160a01b03161561047d5760405162461bcd60e51b815260206004820152601f60248201527f576f726c6450726f78793a20616c726561647920696e697469616c697a656400604482015260640161011f565b80546001600160a01b0319166001600160a01b0392909216919091179055565b6000805160206108ad8339815191526104d7817fa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775336104fd565b6104f35760405162461bcd60e51b815260040161011f9061084b565b6103308383610628565b6000918252600192909201602090815260408083206001600160a01b039094168352929052205460ff1690565b6000805160206108ad83398151915260005b82811015610622576105be7fe2f4eaae4a9751e85a3e4a7b9587827a877f29914755229b07a7b2da98285f7085858481811061057a5761057a610896565b905060200201602081019061058f91906107ad565b600091825260018501602090815260408084206001600160a01b0390931684529190529020805460ff19169055565b8383828181106105d0576105d0610896565b90506020020160208101906105e591906107ad565b6001600160a01b03167f3525e22824a8a7df2c9a6029941c824cf95b6447f1e13d5128fd3826d35afe8b60405160405180910390a260010161053c565b50505050565b6000805160206108ad83398151915260005b8281101561062257600084848381811061065657610656610896565b905060200201602081019061066b91906107ad565b6001600160a01b0316036106cb5760405162461bcd60e51b815260206004820152602160248201527f4261736550726f78793a207369676e6572206973207a65726f206164647265736044820152607360f81b606482015260840161011f565b6107497fe2f4eaae4a9751e85a3e4a7b9587827a877f29914755229b07a7b2da98285f7085858481811061070157610701610896565b905060200201602081019061071691906107ad565b60009182526001808601602090815260408085206001600160a01b0390941685529290529120805460ff19169091179055565b83838281811061075b5761075b610896565b905060200201602081019061077091906107ad565b6001600160a01b03167f47d1c22a25bb3a5d4e481b9b1e6944c2eade3181a0a20b495ed61d35b5323f2460405160405180910390a260010161063a565b6000602082840312156107bf57600080fd5b81356001600160a01b03811681146102c957600080fd5b600080602083850312156107e957600080fd5b823567ffffffffffffffff8082111561080157600080fd5b818501915085601f83011261081557600080fd5b81358181111561082457600080fd5b8660208260051b850101111561083957600080fd5b60209290920196919550909350505050565b6020808252602b908201527f426173654163636573733a2063616c6c657220646f6573206e6f74206861766560408201526a2061646d696e20726f6c6560a81b606082015260800190565b634e487b7160e01b600052603260045260246000fdfe1f07e7b49187e1cf67924ca1fa35732211c5bb2c23b6b53ee47453438de7285ea264697066735822122093210abaa588d44e4fe789f3a408bb334804e5343c78a26cc0de4467c194c58a64736f6c63430008180033";

type NTERC20ProxyConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: NTERC20ProxyConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class NTERC20Proxy__factory extends ContractFactory {
  constructor(...args: NTERC20ProxyConstructorParams) {
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
      NTERC20Proxy & {
        deploymentTransaction(): ContractTransactionResponse;
      }
    >;
  }
  override connect(runner: ContractRunner | null): NTERC20Proxy__factory {
    return super.connect(runner) as NTERC20Proxy__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): NTERC20ProxyInterface {
    return new Interface(_abi) as NTERC20ProxyInterface;
  }
  static connect(
    address: string,
    runner?: ContractRunner | null
  ): NTERC20Proxy {
    return new Contract(address, _abi, runner) as unknown as NTERC20Proxy;
  }
}