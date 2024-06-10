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
  World0_2,
  World0_2Interface,
  WorldConstructorArgsStruct,
} from "../../../../contracts/world/v0.2/World0_2";

const _abi = [
  {
    inputs: [
      {
        components: [
          {
            internalType: "address",
            name: "worldFactory",
            type: "address",
          },
          {
            internalType: "address",
            name: "worldRegistry",
            type: "address",
          },
          {
            internalType: "address",
            name: "companyRegistry",
            type: "address",
          },
          {
            internalType: "address",
            name: "avatarRegistry",
            type: "address",
          },
        ],
        internalType: "struct WorldConstructorArgs",
        name: "args",
        type: "tuple",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    inputs: [],
    name: "ReentrancyGuardReentrantCall",
    type: "error",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "avatar",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "experience",
        type: "address",
      },
    ],
    name: "AvatarRegistered",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "company",
        type: "address",
      },
      {
        components: [
          {
            internalType: "string",
            name: "x",
            type: "string",
          },
          {
            internalType: "string",
            name: "y",
            type: "string",
          },
          {
            internalType: "string",
            name: "z",
            type: "string",
          },
          {
            internalType: "uint256",
            name: "t",
            type: "uint256",
          },
          {
            internalType: "uint256",
            name: "p",
            type: "uint256",
          },
          {
            internalType: "uint256",
            name: "p_sub",
            type: "uint256",
          },
        ],
        indexed: false,
        internalType: "struct VectorAddress",
        name: "vector",
        type: "tuple",
      },
      {
        indexed: false,
        internalType: "string",
        name: "name",
        type: "string",
      },
    ],
    name: "CompanyRegistered",
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
    anonymous: false,
    inputs: [],
    name: "WorldHookRemoved",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "hook",
        type: "address",
      },
    ],
    name: "WorldHookSet",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "oldWorld",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "newWorld",
        type: "address",
      },
    ],
    name: "WorldUpgraded",
    type: "event",
  },
  {
    inputs: [],
    name: "SIGNER_ROLE",
    outputs: [
      {
        internalType: "bytes32",
        name: "",
        type: "bytes32",
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
    name: "addSigners",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "avatarRegistry",
    outputs: [
      {
        internalType: "contract IAvatarRegistry",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "companyRegistry",
    outputs: [
      {
        internalType: "contract ICompanyRegistry",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getBaseVector",
    outputs: [
      {
        components: [
          {
            internalType: "string",
            name: "x",
            type: "string",
          },
          {
            internalType: "string",
            name: "y",
            type: "string",
          },
          {
            internalType: "string",
            name: "z",
            type: "string",
          },
          {
            internalType: "uint256",
            name: "t",
            type: "uint256",
          },
          {
            internalType: "uint256",
            name: "p",
            type: "uint256",
          },
          {
            internalType: "uint256",
            name: "p_sub",
            type: "uint256",
          },
        ],
        internalType: "struct VectorAddress",
        name: "",
        type: "tuple",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getName",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getOwner",
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
        components: [
          {
            internalType: "address",
            name: "owner",
            type: "address",
          },
          {
            internalType: "address",
            name: "oldWorld",
            type: "address",
          },
          {
            components: [
              {
                internalType: "string",
                name: "x",
                type: "string",
              },
              {
                internalType: "string",
                name: "y",
                type: "string",
              },
              {
                internalType: "string",
                name: "z",
                type: "string",
              },
              {
                internalType: "uint256",
                name: "t",
                type: "uint256",
              },
              {
                internalType: "uint256",
                name: "p",
                type: "uint256",
              },
              {
                internalType: "uint256",
                name: "p_sub",
                type: "uint256",
              },
            ],
            internalType: "struct VectorAddress",
            name: "baseVector",
            type: "tuple",
          },
          {
            internalType: "string",
            name: "name",
            type: "string",
          },
          {
            internalType: "bytes",
            name: "initData",
            type: "bytes",
          },
        ],
        internalType: "struct WorldCreateRequest",
        name: "request",
        type: "tuple",
      },
    ],
    name: "init",
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
    inputs: [
      {
        components: [
          {
            internalType: "bool",
            name: "sendTokensToAvatarOwner",
            type: "bool",
          },
          {
            internalType: "address",
            name: "avatarOwner",
            type: "address",
          },
          {
            internalType: "address",
            name: "defaultExperience",
            type: "address",
          },
          {
            internalType: "string",
            name: "username",
            type: "string",
          },
          {
            internalType: "bytes",
            name: "initData",
            type: "bytes",
          },
        ],
        internalType: "struct AvatarRegistrationRequest",
        name: "args",
        type: "tuple",
      },
    ],
    name: "registerAvatar",
    outputs: [
      {
        internalType: "address",
        name: "avatar",
        type: "address",
      },
    ],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        components: [
          {
            internalType: "bool",
            name: "sendTokensToCompanyOwner",
            type: "bool",
          },
          {
            internalType: "address",
            name: "owner",
            type: "address",
          },
          {
            internalType: "string",
            name: "name",
            type: "string",
          },
          {
            internalType: "bytes",
            name: "initData",
            type: "bytes",
          },
        ],
        internalType: "struct CompanyRegistrationArgs",
        name: "args",
        type: "tuple",
      },
    ],
    name: "registerCompany",
    outputs: [
      {
        internalType: "address",
        name: "company",
        type: "address",
      },
    ],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [],
    name: "removeHook",
    outputs: [],
    stateMutability: "nonpayable",
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
        internalType: "contract IWorldHook",
        name: "_hook",
        type: "address",
      },
    ],
    name: "setHook",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes",
        name: "initData",
        type: "bytes",
      },
    ],
    name: "upgrade",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "nextVersion",
        type: "address",
      },
    ],
    name: "upgradeComplete",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "upgraded",
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
    name: "version",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "withdraw",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "worldFactory",
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
    name: "worldRegistry",
    outputs: [
      {
        internalType: "contract IWorldRegistry0_2",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    stateMutability: "payable",
    type: "receive",
  },
] as const;

const _bytecode =
  "0x6101006040523480156200001257600080fd5b5060405162002c7138038062002c7183398101604081905262000035916200025a565b600160005580516001600160a01b0316620000ad5760405162461bcd60e51b815260206004820152602d60248201527f576f726c64305f323a20776f726c64466163746f72792063616e6e6f7420626560448201526c207a65726f206164647265737360981b60648201526084015b60405180910390fd5b60208101516001600160a01b0316620001205760405162461bcd60e51b815260206004820152602e60248201527f576f726c64305f323a20776f726c6452656769737472792063616e6e6f74206260448201526d65207a65726f206164647265737360901b6064820152608401620000a4565b60408101516001600160a01b0316620001955760405162461bcd60e51b815260206004820152603060248201527f576f726c64305f323a20636f6d70616e7952656769737472792063616e6e6f7460448201526f206265207a65726f206164647265737360801b6064820152608401620000a4565b60608101516001600160a01b0316620002095760405162461bcd60e51b815260206004820152602f60248201527f576f726c64305f323a2061766174617252656769737472792063616e6e6f742060448201526e6265207a65726f206164647265737360881b6064820152608401620000a4565b60208101516001600160a01b039081166080528151811660a0526040820151811660c0526060909101511660e052620002ee565b80516001600160a01b03811681146200025557600080fd5b919050565b6000608082840312156200026d57600080fd5b604051608081016001600160401b03811182821017156200029e57634e487b7160e01b600052604160045260246000fd5b604052620002ac836200023d565b8152620002bc602084016200023d565b6020820152620002cf604084016200023d565b6040820152620002e2606084016200023d565b60608201529392505050565b60805160a05160c05160e0516129186200035960003960008181610445015261141f015260008181610411015261097e0152600081816101810152818161154d01526115cc01526000818161039601528181610b7e01528181610bf00152610c6f01526129186000f3fe60806040526004361061012e5760003560e01c806354fd4d50116100ab578063911c2a8c1161006f578063911c2a8c14610384578063a1ebf35d146103b8578063c28de2cd146103da578063c51aba2b146103ff578063e3d7ad7314610433578063e8906a2d1461046757600080fd5b806354fd4d50146102c157806361445eb7146102e45780637df73e2714610304578063893d20e8146103345780638d361e431461036457600080fd5b80632e1a7d4d116100f25780632e1a7d4d14610237578063378f17ff14610257578063382af56d1461026c5780633dfd38731461028e5780634d575f3d146102ae57600080fd5b80630dc3897d1461016f57806317d7de7c146101c05780631c2fbedc146101e257806325394645146101f55780632663d1f71461021757600080fd5b3661016a5760405134815233907f5741979df5f3e491501da74d3b0a83dd2496ab1f34929865b3e190a8ad75859a9060200160405180910390a2005b600080fd5b34801561017b57600080fd5b506101a37f000000000000000000000000000000000000000000000000000000000000000081565b6040516001600160a01b0390911681526020015b60405180910390f35b3480156101cc57600080fd5b506101d5610487565b6040516101b79190611eaa565b6101a36101f0366004612005565b61054a565b34801561020157600080fd5b506102156102103660046120bc565b610aa8565b005b34801561022357600080fd5b5061021561023236600461212e565b610bee565b34801561024357600080fd5b5061021561025236600461214b565b610d0b565b34801561026357600080fd5b50610215610df5565b34801561027857600080fd5b50610281610e93565b6040516101b791906121d7565b34801561029a57600080fd5b506102156102a936600461212e565b6110e3565b6101a36102bc3660046121ea565b6111f5565b3480156102cd57600080fd5b506102d6600281565b6040519081526020016101b7565b3480156102f057600080fd5b506102156102ff366004612364565b61154b565b34801561031057600080fd5b5061032461031f36600461212e565b611afc565b60405190151581526020016101b7565b34801561034057600080fd5b506000805160206128638339815191525461010090046001600160a01b03166101a3565b34801561037057600080fd5b5061021561037f3660046123fc565b611b2d565b34801561039057600080fd5b506101a37f000000000000000000000000000000000000000000000000000000000000000081565b3480156103c457600080fd5b506102d660008051602061288383398151915281565b3480156103e657600080fd5b506000805160206128638339815191525460ff16610324565b34801561040b57600080fd5b506101a37f000000000000000000000000000000000000000000000000000000000000000081565b34801561043f57600080fd5b506101a37f000000000000000000000000000000000000000000000000000000000000000081565b34801561047357600080fd5b506102156104823660046123fc565b611b7b565b7f56d7bc8c87dcf17af82d688c532aeaaf98988789f376198bffdb298b88a9593a8054606091600080516020612863833981519152916104c69061245f565b80601f01602080910402602001604051908101604052809291908181526020018280546104f29061245f565b801561053f5780601f106105145761010080835404028352916020019161053f565b820191906000526020600020905b81548152906001019060200180831161052257829003601f168201915b505050505091505090565b60006000805160206128438339815191526105748160008051602061288383398151915233611bc9565b6105995760405162461bcd60e51b815260040161059090612493565b60405180910390fd5b6105a1611bf6565b60208301516001600160a01b03166106125760405162461bcd60e51b815260206004820152602e60248201527f576f726c64305f323a20636f6d70616e79206f776e65722063616e6e6f74206260448201526d65207a65726f206164647265737360901b6064820152608401610590565b6000836040015151116106765760405162461bcd60e51b815260206004820152602660248201527f576f726c64305f323a20636f6d70616e79206e616d652063616e6e6f7420626560448201526520656d70747960d01b6064820152608401610590565b6000805160206128a383398151915254600080516020612863833981519152906001600160a01b03161561077a57600281015460405163e76c26f760e01b81526001600160a01b039091169063e76c26f7906106d69087906004016124df565b6020604051808303816000875af11580156106f5573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610719919061253f565b61077a5760405162461bcd60e51b815260206004820152602c60248201527f576f726c64305f323a20686f6f6b2072656a656374656420636f6d70616e792060448201526b3932b3b4b9ba3930ba34b7b760a11b6064820152608401610590565b80600a016000815461078b9061255c565b9190508190555060006040518060c001604052808360030160000180546107b19061245f565b80601f01602080910402602001604051908101604052809291908181526020018280546107dd9061245f565b801561082a5780601f106107ff5761010080835404028352916020019161082a565b820191906000526020600020905b81548152906001019060200180831161080d57829003601f168201915b505050505081526020018360030160010180546108469061245f565b80601f01602080910402602001604051908101604052809291908181526020018280546108729061245f565b80156108bf5780601f10610894576101008083540402835291602001916108bf565b820191906000526020600020905b8154815290600101906020018083116108a257829003601f168201915b505050505081526020018360030160020180546108db9061245f565b80601f01602080910402602001604051908101604052809291908181526020018280546109079061245f565b80156109545780601f1061092957610100808354040283529160200191610954565b820191906000526020600020905b81548152906001019060200180831161093757829003601f168201915b505050505081526020018360030160030154815260200183600a01548152602001600081525090507f00000000000000000000000000000000000000000000000000000000000000006001600160a01b03166322feaee6346040518060a0016040528089600001511515815260200189602001516001600160a01b031681526020018581526020018960600151815260200189604001518152506040518363ffffffff1660e01b8152600401610a0a9190612583565b60206040518083038185885af1158015610a28573d6000803e3d6000fd5b50505050506040513d601f19601f82011682018060405250810190610a4d91906125f9565b9350836001600160a01b03167f3ae5cc94bcf37dd89d282cbe7f9842a176a101aa41ce7af3ed66fa58a2466c62828760400151604051610a8e929190612616565b60405180910390a25050610aa26001600055565b50919050565b600080516020612843833981519152610ad0816000805160206128c383398151915233611bc9565b610aec5760405162461bcd60e51b81526004016105909061263b565b600080516020612863833981519152805460ff1615610b4d5760405162461bcd60e51b815260206004820181905260248201527f576f726c64305f323a20776f726c6420616c72656164792075706772616465646044820152606401610590565b600080516020612863833981519152805460ff19166001178155604051638f51aa6d60e01b81526001600160a01b037f00000000000000000000000000000000000000000000000000000000000000001690638f51aa6d90610bb59088908890600401612686565b600060405180830381600087803b158015610bcf57600080fd5b505af1158015610be3573d6000803e3d6000fd5b505050505050505050565b7f00000000000000000000000000000000000000000000000000000000000000006001600160a01b0316610c645760405162461bcd60e51b815260206004820152601f60248201527f576f726c64305f323a20776f726c645265676973747279206e6f7420736574006044820152606401610590565b336001600160a01b037f00000000000000000000000000000000000000000000000000000000000000001614610cdc5760405162461bcd60e51b815260206004820181905260248201527f576f726c64305f323a2063616c6c6572206973206e6f742072656769737472796044820152606401610590565b60008051602061284383398151915280546001600160a01b0319166001600160a01b0392909216919091179055565b600080516020612843833981519152610d33816000805160206128c383398151915233611bc9565b610d4f5760405162461bcd60e51b81526004016105909061263b565b47821115610d9f5760405162461bcd60e51b815260206004820181905260248201527f576f726c64305f323a20616d6f756e7420657863656564732062616c616e63656044820152606401610590565b6000600080516020612863833981519152805460405191925061010090046001600160a01b0316906108fc8515029085906000818181858888f19350505050158015610def573d6000803e3d6000fd5b50505050565b600080516020612843833981519152610e1d816000805160206128c383398151915233611bc9565b610e395760405162461bcd60e51b81526004016105909061263b565b6000805160206128a383398151915280546001600160a01b0319169055604051600080516020612863833981519152907fd6bb5977e74678fe79d7effa6d93a6e996630cf696c32a815b00fda893b87b5a90600090a15050565b610ecc6040518060c001604052806060815260200160608152602001606081526020016000815260200160008152602001600081525090565b6040805160c081019091527f56d7bc8c87dcf17af82d688c532aeaaf98988789f376198bffdb298b88a95934805460008051602061286383398151915292919082908290610f199061245f565b80601f0160208091040260200160405190810160405280929190818152602001828054610f459061245f565b8015610f925780601f10610f6757610100808354040283529160200191610f92565b820191906000526020600020905b815481529060010190602001808311610f7557829003601f168201915b50505050508152602001600182018054610fab9061245f565b80601f0160208091040260200160405190810160405280929190818152602001828054610fd79061245f565b80156110245780601f10610ff957610100808354040283529160200191611024565b820191906000526020600020905b81548152906001019060200180831161100757829003601f168201915b5050505050815260200160028201805461103d9061245f565b80601f01602080910402602001604051908101604052809291908181526020018280546110699061245f565b80156110b65780601f1061108b576101008083540402835291602001916110b6565b820191906000526020600020905b81548152906001019060200180831161109957829003601f168201915b50505050508152602001600382015481526020016004820154815260200160058201548152505091505090565b60008051602061284383398151915261110b816000805160206128c383398151915233611bc9565b6111275760405162461bcd60e51b81526004016105909061263b565b6001600160a01b03821661118b5760405162461bcd60e51b815260206004820152602560248201527f576f726c64305f323a20686f6f6b2063616e6e6f74206265207a65726f206164604482015264647265737360d81b6064820152608401610590565b6000805160206128a383398151915280546001600160a01b0319166001600160a01b03841690811790915560405160008051602061286383398151915291907f2e0d4a0d6b6807573b280bc3dd0c83d52c5115e86a427cc6506e9a040f64b47790600090a2505050565b600060008051602061284383398151915261121f8160008051602061288383398151915233611bc9565b61123b5760405162461bcd60e51b815260040161059090612493565b611243611bf6565b60208301516001600160a01b03166112b35760405162461bcd60e51b815260206004820152602d60248201527f576f726c64305f323a20617661746172206f776e65722063616e6e6f7420626560448201526c207a65726f206164647265737360981b6064820152608401610590565b60008360600151511161131a5760405162461bcd60e51b815260206004820152602960248201527f576f726c64305f323a2061766174617220757365726e616d652063616e6e6f7460448201526820626520656d70747960b81b6064820152608401610590565b6000805160206128a383398151915254600080516020612863833981519152906001600160a01b03161561141d576002810154604051633e6ff77160e21b81526001600160a01b039091169063f9bfddc49061137a9087906004016126b5565b6020604051808303816000875af1158015611399573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906113bd919061253f565b61141d5760405162461bcd60e51b815260206004820152602b60248201527f576f726c64305f323a20686f6f6b2072656a656374656420617661746172207260448201526a32b3b4b9ba3930ba34b7b760a91b6064820152608401610590565b7f00000000000000000000000000000000000000000000000000000000000000006001600160a01b0316634d575f3d6040518060a0016040528087600001511515815260200187602001516001600160a01b0316815260200187604001516001600160a01b031681526020018760600151815260200187608001518152506040518263ffffffff1660e01b81526004016114b791906126b5565b6020604051808303816000875af11580156114d6573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906114fa91906125f9565b925083604001516001600160a01b0316836001600160a01b03167f0ada65c939d4c317368a1a88ef5f00697bfe4e748e24d6722c1a0d04c26a4b8660405160405180910390a350610aa26001600055565b7f00000000000000000000000000000000000000000000000000000000000000006001600160a01b03166115c15760405162461bcd60e51b815260206004820152601e60248201527f576f726c64305f323a20776f726c64466163746f7279206e6f742073657400006044820152606401610590565b336001600160a01b037f000000000000000000000000000000000000000000000000000000000000000016146116395760405162461bcd60e51b815260206004820152601f60248201527f576f726c64305f323a2063616c6c6572206973206e6f7420666163746f7279006044820152606401610590565b8051600080516020612843833981519152906001600160a01b03166116af5760405162461bcd60e51b815260206004820152602660248201527f576f726c64305f323a206f776e65722063616e6e6f74206265207a65726f206160448201526564647265737360d01b6064820152608401610590565b604082015151516000036117135760405162461bcd60e51b815260206004820152602560248201527f576f726c64305f323a2062617365566563746f722e782063616e6e6f74206265604482015264207a65726f60d81b6064820152608401610590565b8160400151602001515160000361177a5760405162461bcd60e51b815260206004820152602560248201527f576f726c64305f323a2062617365566563746f722e792063616e6e6f74206265604482015264207a65726f60d81b6064820152608401610590565b816040015160400151516000036117e15760405162461bcd60e51b815260206004820152602560248201527f576f726c64305f323a2062617365566563746f722e7a2063616e6e6f74206265604482015264207a65726f60d81b6064820152608401610590565b604082015160800151156118435760405162461bcd60e51b815260206004820152602360248201527f576f726c64305f323a2062617365566563746f722e70206d757374206265207a60448201526265726f60e81b6064820152608401610590565b604082015160a00151156118a95760405162461bcd60e51b815260206004820152602760248201527f576f726c64305f323a2062617365566563746f722e705f737562206d757374206044820152666265207a65726f60c81b6064820152608401610590565b6000826060015151116118fe5760405162461bcd60e51b815260206004820152601e60248201527f576f726c64305f323a206e616d652063616e6e6f7420626520656d70747900006044820152606401610590565b815160008051602061286383398151915280546001600160a01b0390921661010002610100600160a81b0319909216919091178155604083015180517f56d7bc8c87dcf17af82d688c532aeaaf98988789f376198bffdb298b88a95934908190611968908261276c565b506020820151600182019061197d908261276c565b5060408201516002820190611992908261276c565b5060608281015160038301556080830151600483015560a09092015160059091015583015160098201906119c6908261276c565b506000600a8201556020830151600180830180546001600160a01b0319166001600160a01b039384161790558254611a189285926000805160206128c383398151915292610100900490911690611c20565b8054611a459083906000805160206128838339815191529061010090046001600160a01b03166001611c20565b60208301516001600160a01b031615611af757600083602001516001600160a01b031663893d20e86040518163ffffffff1660e01b8152600401602060405180830381865afa158015611a9c573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190611ac091906125f9565b82549091506001600160a01b038083166101009092041614610def57610def83600080516020612883833981519152836001611c20565b505050565b6000600080516020612843833981519152611b268160008051602061288383398151915285611bc9565b9392505050565b600080516020612843833981519152611b55816000805160206128c383398151915233611bc9565b611b715760405162461bcd60e51b81526004016105909061263b565b611af78383611c59565b600080516020612843833981519152611ba3816000805160206128c383398151915233611bc9565b611bbf5760405162461bcd60e51b81526004016105909061263b565b611af78383611d1a565b6000918252600192909201602090815260408083206001600160a01b039094168352929052205460ff1690565b600260005403611c1957604051633ee5aeb560e01b815260040160405180910390fd5b6002600055565b60009283526001909301602090815260408084206001600160a01b0390931684529190529020805491151560ff19909216919091179055565b60008051602061284383398151915260005b82811015610def57611cb6600080516020612883833981519152858584818110611c9757611c9761282c565b9050602002016020810190611cac919061212e565b8491906000611c20565b838382818110611cc857611cc861282c565b9050602002016020810190611cdd919061212e565b6001600160a01b03167f3525e22824a8a7df2c9a6029941c824cf95b6447f1e13d5128fd3826d35afe8b60405160405180910390a2600101611c6b565b60008051602061284383398151915260005b82811015610def576000848483818110611d4857611d4861282c565b9050602002016020810190611d5d919061212e565b6001600160a01b031603611dbd5760405162461bcd60e51b815260206004820152602160248201527f4261736550726f78793a207369676e6572206973207a65726f206164647265736044820152607360f81b6064820152608401610590565b611e00600080516020612883833981519152858584818110611de157611de161282c565b9050602002016020810190611df6919061212e565b8491906001611c20565b838382818110611e1257611e1261282c565b9050602002016020810190611e27919061212e565b6001600160a01b03167f47d1c22a25bb3a5d4e481b9b1e6944c2eade3181a0a20b495ed61d35b5323f2460405160405180910390a2600101611d2c565b6000815180845260005b81811015611e8a57602081850181015186830182015201611e6e565b506000602082860101526020601f19601f83011685010191505092915050565b602081526000611b266020830184611e64565b634e487b7160e01b600052604160045260246000fd5b6040516080810167ffffffffffffffff81118282101715611ef657611ef6611ebd565b60405290565b60405160a0810167ffffffffffffffff81118282101715611ef657611ef6611ebd565b60405160c0810167ffffffffffffffff81118282101715611ef657611ef6611ebd565b8015158114611f5057600080fd5b50565b6001600160a01b0381168114611f5057600080fd5b8035611f7381611f53565b919050565b600082601f830112611f8957600080fd5b813567ffffffffffffffff80821115611fa457611fa4611ebd565b604051601f8301601f19908116603f01168101908282118183101715611fcc57611fcc611ebd565b81604052838152866020858801011115611fe557600080fd5b836020870160208301376000602085830101528094505050505092915050565b60006020828403121561201757600080fd5b813567ffffffffffffffff8082111561202f57600080fd5b908301906080828603121561204357600080fd5b61204b611ed3565b823561205681611f42565b8152602083013561206681611f53565b602082015260408301358281111561207d57600080fd5b61208987828601611f78565b6040830152506060830135828111156120a157600080fd5b6120ad87828601611f78565b60608301525095945050505050565b600080602083850312156120cf57600080fd5b823567ffffffffffffffff808211156120e757600080fd5b818501915085601f8301126120fb57600080fd5b81358181111561210a57600080fd5b86602082850101111561211c57600080fd5b60209290920196919550909350505050565b60006020828403121561214057600080fd5b8135611b2681611f53565b60006020828403121561215d57600080fd5b5035919050565b6000815160c0845261217960c0850182611e64565b9050602083015184820360208601526121928282611e64565b915050604083015184820360408601526121ac8282611e64565b915050606083015160608501526080830151608085015260a083015160a08501528091505092915050565b602081526000611b266020830184612164565b6000602082840312156121fc57600080fd5b813567ffffffffffffffff8082111561221457600080fd5b9083019060a0828603121561222857600080fd5b612230611efc565b823561223b81611f42565b8152602083013561224b81611f53565b602082015261225c60408401611f68565b604082015260608301358281111561227357600080fd5b61227f87828601611f78565b60608301525060808301358281111561229757600080fd5b6122a387828601611f78565b60808301525095945050505050565b600060c082840312156122c457600080fd5b6122cc611f1f565b9050813567ffffffffffffffff808211156122e657600080fd5b6122f285838601611f78565b8352602084013591508082111561230857600080fd5b61231485838601611f78565b6020840152604084013591508082111561232d57600080fd5b5061233a84828501611f78565b604083015250606082013560608201526080820135608082015260a082013560a082015292915050565b60006020828403121561237657600080fd5b813567ffffffffffffffff8082111561238e57600080fd5b9083019060a082860312156123a257600080fd5b6123aa611efc565b6123b383611f68565b81526123c160208401611f68565b60208201526040830135828111156123d857600080fd5b6123e4878286016122b2565b60408301525060608301358281111561227357600080fd5b6000806020838503121561240f57600080fd5b823567ffffffffffffffff8082111561242757600080fd5b818501915085601f83011261243b57600080fd5b81358181111561244a57600080fd5b8660208260051b850101111561211c57600080fd5b600181811c9082168061247357607f821691505b602082108103610aa257634e487b7160e01b600052602260045260246000fd5b6020808252602c908201527f426173654163636573733a2063616c6c657220646f6573206e6f74206861766560408201526b207369676e657220726f6c6560a01b606082015260800190565b6020815281511515602082015260018060a01b036020830151166040820152600060408301516080606084015261251960a0840182611e64565b90506060840151601f198483030160808501526125368282611e64565b95945050505050565b60006020828403121561255157600080fd5b8151611b2681611f42565b60006001820161257c57634e487b7160e01b600052601160045260246000fd5b5060010190565b6020815281511515602082015260018060a01b0360208301511660408201526000604083015160a060608401526125bd60c0840182612164565b90506060840151601f19808584030160808601526125db8383611e64565b925060808601519150808584030160a0860152506125368282611e64565b60006020828403121561260b57600080fd5b8151611b2681611f53565b6040815260006126296040830185612164565b82810360208401526125368185611e64565b6020808252602b908201527f426173654163636573733a2063616c6c657220646f6573206e6f74206861766560408201526a2061646d696e20726f6c6560a81b606082015260800190565b60208152816020820152818360408301376000818301604090810191909152601f909201601f19160101919050565b602081528151151560208201526000602083015160018060a01b0380821660408501528060408601511660608501525050606083015160a060808401526126ff60c0840182611e64565b90506080840151601f198483030160a08501526125368282611e64565b601f821115611af7576000816000526020600020601f850160051c810160208610156127455750805b601f850160051c820191505b8181101561276457828155600101612751565b505050505050565b815167ffffffffffffffff81111561278657612786611ebd565b61279a81612794845461245f565b8461271c565b602080601f8311600181146127cf57600084156127b75750858301515b600019600386901b1c1916600185901b178555612764565b600085815260208120601f198616915b828110156127fe578886015182559484019460019091019084016127df565b508582101561281c5787850151600019600388901b60f8161c191681555b5050505050600190811b01905550565b634e487b7160e01b600052603260045260246000fdfe1f07e7b49187e1cf67924ca1fa35732211c5bb2c23b6b53ee47453438de7285e56d7bc8c87dcf17af82d688c532aeaaf98988789f376198bffdb298b88a95931e2f4eaae4a9751e85a3e4a7b9587827a877f29914755229b07a7b2da98285f7056d7bc8c87dcf17af82d688c532aeaaf98988789f376198bffdb298b88a95933a49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775a264697066735822122051dea2f673720a302494e0e53e6e1f82d6e6fb0d1f04c285e03b58a73a7f9d2864736f6c63430008180033";

type World0_2ConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: World0_2ConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class World0_2__factory extends ContractFactory {
  constructor(...args: World0_2ConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override getDeployTransaction(
    args: WorldConstructorArgsStruct,
    overrides?: NonPayableOverrides & { from?: string }
  ): Promise<ContractDeployTransaction> {
    return super.getDeployTransaction(args, overrides || {});
  }
  override deploy(
    args: WorldConstructorArgsStruct,
    overrides?: NonPayableOverrides & { from?: string }
  ) {
    return super.deploy(args, overrides || {}) as Promise<
      World0_2 & {
        deploymentTransaction(): ContractTransactionResponse;
      }
    >;
  }
  override connect(runner: ContractRunner | null): World0_2__factory {
    return super.connect(runner) as World0_2__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): World0_2Interface {
    return new Interface(_abi) as World0_2Interface;
  }
  static connect(address: string, runner?: ContractRunner | null): World0_2 {
    return new Contract(address, _abi, runner) as unknown as World0_2;
  }
}