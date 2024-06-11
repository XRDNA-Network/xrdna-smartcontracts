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
  ExperienceProxy,
  ExperienceProxyInterface,
  BaseProxyConstructorArgsStruct,
} from "../../../contracts/experience/ExperienceProxy";

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
  "0x60c060405234801561001057600080fd5b50604051610c30380380610c3083398101604081905261002f9161013a565b805181906001600160a01b03166100985760405162461bcd60e51b815260206004820152602260248201527f4261736550726f78793a20666163746f7279206973207a65726f206164647265604482015261737360f01b60648201526084015b60405180910390fd5b60208101516001600160a01b03166100fe5760405162461bcd60e51b815260206004820152602360248201527f4261736550726f78793a207265676973747279206973207a65726f206164647260448201526265737360e81b606482015260840161008f565b80516001600160a01b039081166080526020909101511660a052506101a2565b80516001600160a01b038116811461013557600080fd5b919050565b60006040828403121561014c57600080fd5b604080519081016001600160401b038111828210171561017c57634e487b7160e01b600052604160045260246000fd5b6040526101888361011e565b81526101966020840161011e565b60208201529392505050565b60805160a051610a5b6101d560003960008181610172015261053d01526000818161025e01526103d50152610a5b6000f3fe60806040526004361061007f5760003560e01c8063aaf10f421161004e578063aaf10f4214610221578063c45a01551461024c578063d784d42614610280578063e8906a2d146102a0576100c4565b80637b103999146101605780637df73e27146101b15780638d361e43146101e15780639c02006114610201576100c4565b366100c45760405134815233907f5741979df5f3e491501da74d3b0a83dd2496ab1f34929865b3e190a8ad75859a9060200160405180910390a26100c2346102c0565b005b600080516020610a0683398151915280546001600160a01b03168061013b5760405162461bcd60e51b815260206004820152602260248201527f576f726c6450726f78793a20696d706c656d656e746174696f6e206e6f742073604482015261195d60f21b60648201526084015b60405180910390fd5b60405136600082376000803683855af43d806000843e81801561015c578184f35b8184fd5b34801561016c57600080fd5b506101947f000000000000000000000000000000000000000000000000000000000000000081565b6040516001600160a01b0390911681526020015b60405180910390f35b3480156101bd57600080fd5b506101d16101cc366004610906565b610327565b60405190151581526020016101a8565b3480156101ed57600080fd5b506100c26101fc36600461092f565b61036a565b34801561020d57600080fd5b506100c261021c366004610906565b6103ca565b34801561022d57600080fd5b50600080516020610a06833981519152546001600160a01b0316610194565b34801561025857600080fd5b506101947f000000000000000000000000000000000000000000000000000000000000000081565b34801561028c57600080fd5b506100c261029b366004610906565b610532565b3480156102ac57600080fd5b506100c26102bb36600461092f565b61060b565b60007f7ea04aef6bca987a4816974a9eadce73182071dd7a8e8812099e1d973c1ae505805460405191925061010090046001600160a01b0316906108fc8415029084906000818181858888f19350505050158015610322573d6000803e3d6000fd5b505050565b6000600080516020610a06833981519152610363817fe2f4eaae4a9751e85a3e4a7b9587827a877f29914755229b07a7b2da98285f708561066b565b9392505050565b600080516020610a068339815191526103a4817fa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c217753361066b565b6103c05760405162461bcd60e51b8152600401610132906109a4565b6103228383610698565b336001600160a01b037f000000000000000000000000000000000000000000000000000000000000000016146104425760405162461bcd60e51b815260206004820181905260248201527f4261736550726f78793a2063616c6c6572206973206e6f7420666163746f72796044820152606401610132565b6001600160a01b0381166104ab5760405162461bcd60e51b815260206004820152602a60248201527f576f726c6450726f78793a20696d706c656d656e746174696f6e206973207a65604482015269726f206164647265737360b01b6064820152608401610132565b600080516020610a0683398151915280546001600160a01b0316156105125760405162461bcd60e51b815260206004820152601f60248201527f576f726c6450726f78793a20616c726561647920696e697469616c697a6564006044820152606401610132565b80546001600160a01b0319166001600160a01b0392909216919091179055565b336001600160a01b037f000000000000000000000000000000000000000000000000000000000000000016146105b45760405162461bcd60e51b815260206004820152602160248201527f4261736550726f78793a2063616c6c6572206973206e6f7420726567697374726044820152607960f81b6064820152608401610132565b600080516020610a0683398151915280546001600160a01b0319166001600160a01b03831690811782556040517f2989b377844ae55f0ca303ad21490d8519f8cf871ad6b5ba3dbec736bb54c63f90600090a25050565b600080516020610a06833981519152610645817fa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c217753361066b565b6106615760405162461bcd60e51b8152600401610132906109a4565b6103228383610771565b6000918252600192909201602090815260408083206001600160a01b039094168352929052205460ff1690565b600080516020610a0683398151915260005b8281101561076b576107077fe2f4eaae4a9751e85a3e4a7b9587827a877f29914755229b07a7b2da98285f708585848181106106e8576106e86109ef565b90506020020160208101906106fd9190610906565b84919060006108cd565b838382818110610719576107196109ef565b905060200201602081019061072e9190610906565b6001600160a01b03167f3525e22824a8a7df2c9a6029941c824cf95b6447f1e13d5128fd3826d35afe8b60405160405180910390a26001016106aa565b50505050565b600080516020610a0683398151915260005b8281101561076b57600084848381811061079f5761079f6109ef565b90506020020160208101906107b49190610906565b6001600160a01b0316036108145760405162461bcd60e51b815260206004820152602160248201527f4261736550726f78793a207369676e6572206973207a65726f206164647265736044820152607360f81b6064820152608401610132565b6108697fe2f4eaae4a9751e85a3e4a7b9587827a877f29914755229b07a7b2da98285f7085858481811061084a5761084a6109ef565b905060200201602081019061085f9190610906565b84919060016108cd565b83838281811061087b5761087b6109ef565b90506020020160208101906108909190610906565b6001600160a01b03167f47d1c22a25bb3a5d4e481b9b1e6944c2eade3181a0a20b495ed61d35b5323f2460405160405180910390a2600101610783565b60009283526001909301602090815260408084206001600160a01b0390931684529190529020805491151560ff19909216919091179055565b60006020828403121561091857600080fd5b81356001600160a01b038116811461036357600080fd5b6000806020838503121561094257600080fd5b823567ffffffffffffffff8082111561095a57600080fd5b818501915085601f83011261096e57600080fd5b81358181111561097d57600080fd5b8660208260051b850101111561099257600080fd5b60209290920196919550909350505050565b6020808252602b908201527f426173654163636573733a2063616c6c657220646f6573206e6f74206861766560408201526a2061646d696e20726f6c6560a81b606082015260800190565b634e487b7160e01b600052603260045260246000fdfe1f07e7b49187e1cf67924ca1fa35732211c5bb2c23b6b53ee47453438de7285ea264697066735822122081f569583dff7d5316fa99a906083793ef7d223f60fc72756ee6f526abcf950364736f6c63430008180033";

type ExperienceProxyConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: ExperienceProxyConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class ExperienceProxy__factory extends ContractFactory {
  constructor(...args: ExperienceProxyConstructorParams) {
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
      ExperienceProxy & {
        deploymentTransaction(): ContractTransactionResponse;
      }
    >;
  }
  override connect(runner: ContractRunner | null): ExperienceProxy__factory {
    return super.connect(runner) as ExperienceProxy__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): ExperienceProxyInterface {
    return new Interface(_abi) as ExperienceProxyInterface;
  }
  static connect(
    address: string,
    runner?: ContractRunner | null
  ): ExperienceProxy {
    return new Contract(address, _abi, runner) as unknown as ExperienceProxy;
  }
}
