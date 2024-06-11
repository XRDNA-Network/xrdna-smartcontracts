/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import {
  Contract,
  ContractFactory,
  ContractTransactionResponse,
  Interface,
} from "ethers";
import type {
  Signer,
  AddressLike,
  ContractDeployTransaction,
  ContractRunner,
} from "ethers";
import type { NonPayableOverrides } from "../../../../common";
import type {
  PortalRegistry,
  PortalRegistryInterface,
} from "../../../../contracts/portal/PortalRegistry.sol/PortalRegistry";

const _abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "mainAdmin",
        type: "address",
      },
      {
        internalType: "address[]",
        name: "admins",
        type: "address[]",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    inputs: [],
    name: "AccessControlBadConfirmation",
    type: "error",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        internalType: "bytes32",
        name: "neededRole",
        type: "bytes32",
      },
    ],
    name: "AccessControlUnauthorizedAccount",
    type: "error",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "uint256",
        name: "portalId",
        type: "uint256",
      },
      {
        indexed: true,
        internalType: "address",
        name: "avatar",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "destination",
        type: "address",
      },
    ],
    name: "JumpSuccessful",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "uint256",
        name: "portalId",
        type: "uint256",
      },
      {
        indexed: true,
        internalType: "address",
        name: "experience",
        type: "address",
      },
    ],
    name: "PortalAdded",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "uint256",
        name: "portalId",
        type: "uint256",
      },
      {
        indexed: true,
        internalType: "address",
        name: "condition",
        type: "address",
      },
    ],
    name: "PortalConditionAdded",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "uint256",
        name: "portalId",
        type: "uint256",
      },
    ],
    name: "PortalConditionRemoved",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "uint256",
        name: "portalId",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "address",
        name: "oldExperience",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "newExperience",
        type: "address",
      },
    ],
    name: "PortalDestinationUpgraded",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "uint256",
        name: "portalId",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "newFee",
        type: "uint256",
      },
    ],
    name: "PortalFeeChanged",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "newRegistry",
        type: "address",
      },
    ],
    name: "PortalRegistryUpgraded",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        indexed: true,
        internalType: "bytes32",
        name: "previousAdminRole",
        type: "bytes32",
      },
      {
        indexed: true,
        internalType: "bytes32",
        name: "newAdminRole",
        type: "bytes32",
      },
    ],
    name: "RoleAdminChanged",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "sender",
        type: "address",
      },
    ],
    name: "RoleGranted",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "sender",
        type: "address",
      },
    ],
    name: "RoleRevoked",
    type: "event",
  },
  {
    inputs: [],
    name: "ADMIN_ROLE",
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
    inputs: [],
    name: "DEFAULT_ADMIN_ROLE",
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
        internalType: "contract IPortalCondition",
        name: "condition",
        type: "address",
      },
    ],
    name: "addCondition",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        components: [
          {
            internalType: "contract IExperience",
            name: "destination",
            type: "address",
          },
          {
            internalType: "uint256",
            name: "fee",
            type: "uint256",
          },
        ],
        internalType: "struct AddPortalRequest",
        name: "req",
        type: "tuple",
      },
    ],
    name: "addPortal",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
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
    inputs: [
      {
        internalType: "uint256",
        name: "newFee",
        type: "uint256",
      },
    ],
    name: "changePortalFee",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "experienceRegistry",
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
        name: "experience",
        type: "address",
      },
    ],
    name: "getIdForExperience",
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
        name: "va",
        type: "tuple",
      },
    ],
    name: "getIdForVectorAddress",
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
        internalType: "address",
        name: "experience",
        type: "address",
      },
    ],
    name: "getPortalInfoByAddress",
    outputs: [
      {
        components: [
          {
            internalType: "contract IExperience",
            name: "destination",
            type: "address",
          },
          {
            internalType: "contract IPortalCondition",
            name: "condition",
            type: "address",
          },
          {
            internalType: "uint256",
            name: "fee",
            type: "uint256",
          },
        ],
        internalType: "struct PortalInfo",
        name: "",
        type: "tuple",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "portalId",
        type: "uint256",
      },
    ],
    name: "getPortalInfoById",
    outputs: [
      {
        components: [
          {
            internalType: "contract IExperience",
            name: "destination",
            type: "address",
          },
          {
            internalType: "contract IPortalCondition",
            name: "condition",
            type: "address",
          },
          {
            internalType: "uint256",
            name: "fee",
            type: "uint256",
          },
        ],
        internalType: "struct PortalInfo",
        name: "",
        type: "tuple",
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
        name: "va",
        type: "tuple",
      },
    ],
    name: "getPortalInfoByVectorAddress",
    outputs: [
      {
        components: [
          {
            internalType: "contract IExperience",
            name: "destination",
            type: "address",
          },
          {
            internalType: "contract IPortalCondition",
            name: "condition",
            type: "address",
          },
          {
            internalType: "uint256",
            name: "fee",
            type: "uint256",
          },
        ],
        internalType: "struct PortalInfo",
        name: "",
        type: "tuple",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
    ],
    name: "getRoleAdmin",
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
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
    ],
    name: "grantRole",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
    ],
    name: "hasRole",
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
        internalType: "uint256",
        name: "portalId",
        type: "uint256",
      },
    ],
    name: "jumpRequest",
    outputs: [
      {
        internalType: "bytes",
        name: "",
        type: "bytes",
      },
    ],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [],
    name: "removeCondition",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "callerConfirmation",
        type: "address",
      },
    ],
    name: "renounceRole",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
    ],
    name: "revokeRole",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "registry",
        type: "address",
      },
    ],
    name: "setAvatarRegistry",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "registry",
        type: "address",
      },
    ],
    name: "setExperienceRegistry",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes4",
        name: "interfaceId",
        type: "bytes4",
      },
    ],
    name: "supportsInterface",
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
        internalType: "address",
        name: "oldExperience",
        type: "address",
      },
      {
        internalType: "address",
        name: "newExperience",
        type: "address",
      },
    ],
    name: "upgradeExperiencePortal",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "newRegistry",
        type: "address",
      },
    ],
    name: "upgradeRegistry",
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
    stateMutability: "payable",
    type: "receive",
  },
] as const;

const _bytecode =
  "0x60806040523480156200001157600080fd5b50604051620029a8380380620029a88339810160408190526200003491620002a2565b6001600160a01b038216620000a75760405162461bcd60e51b815260206004820152602e60248201527f506f7274616c52656769737472793a206d61696e2061646d696e20616464726560448201526d073732063616e6e6f7420626520360941b60648201526084015b60405180910390fd5b620000b4600083620001c0565b50620000d06000805160206200298883398151915283620001c0565b5060005b8151811015620001b75760006001600160a01b0316828281518110620000fe57620000fe6200038b565b60200260200101516001600160a01b031603620001705760405162461bcd60e51b815260206004820152602960248201527f506f7274616c52656769737472793a2061646d696e206164647265737320636160448201526806e6e6f7420626520360bc1b60648201526084016200009e565b620001ad600080516020620029888339815191528383815181106200019957620001996200038b565b6020026020010151620001c060201b60201c565b50600101620000d4565b505050620003a1565b6000828152602081815260408083206001600160a01b038516845290915281205460ff1662000265576000838152602081815260408083206001600160a01b03861684529091529020805460ff191660011790556200021c3390565b6001600160a01b0316826001600160a01b0316847f2f8788117e7eff1d82e926ec794901d17c78024a50270940304540a733656f0d60405160405180910390a450600162000269565b5060005b92915050565b80516001600160a01b03811681146200028757600080fd5b919050565b634e487b7160e01b600052604160045260246000fd5b60008060408385031215620002b657600080fd5b620002c1836200026f565b602084810151919350906001600160401b0380821115620002e157600080fd5b818601915086601f830112620002f657600080fd5b8151818111156200030b576200030b6200028c565b8060051b604051601f19603f830116810181811085821117156200033357620003336200028c565b6040529182528482019250838101850191898311156200035257600080fd5b938501935b828510156200037b576200036b856200026f565b8452938501939285019262000357565b8096505050505050509250929050565b634e487b7160e01b600052603260045260246000fd5b6125d780620003b16000396000f3fe60806040526004361061016a5760003560e01c80637e6e0602116100d1578063a6c075d41161008a578063c349e28911610064578063c349e28914610546578063c512205c14610566578063d547741f14610586578063e3d7ad73146105a657600080fd5b8063a6c075d41461048c578063aa7ff6b7146104ac578063c28de2cd1461052c57600080fd5b80637e6e0602146103ba57806383c34263146103da57806384c4484e146103fa5780638f09a6be1461041a57806391d1485414610457578063a217fddf1461047757600080fd5b8063288b568411610123578063288b5684146102905780632f2ff15d1461030257806336568abe146103225780633b19e880146103425780633c3f5ff41461037857806375b238fc1461039857600080fd5b806301ffc9a714610176578063021665b7146101ab578063102ea6ae146101c2578063194663891461021257806322d3493214610240578063248a9ca31461026057600080fd5b3661017157005b600080fd5b34801561018257600080fd5b50610196610191366004611e31565b6105c6565b60405190151581526020015b60405180910390f35b3480156101b757600080fd5b506101c06105fd565b005b3480156101ce57600080fd5b506101e26101dd366004611f49565b6106b5565b6040805182516001600160a01b0390811682526020808501519091169082015291810151908201526060016101a2565b34801561021e57600080fd5b5061023261022d366004611f49565b61074a565b6040519081526020016101a2565b34801561024c57600080fd5b506101c061025b366004612034565b610792565b34801561026c57600080fd5b5061023261027b366004612051565b60009081526020819052604090206001015490565b34801561029c57600080fd5b506101e26102ab366004612051565b60408051606080820183526000808352602080840182905292840181905293845260038252928290208251938401835280546001600160a01b03908116855260018201541691840191909152600201549082015290565b34801561030e57600080fd5b506101c061031d36600461206a565b6108be565b34801561032e57600080fd5b506101c061033d36600461206a565b6108e9565b34801561034e57600080fd5b5061023261035d366004612034565b6001600160a01b031660009081526005602052604090205490565b34801561038457600080fd5b5061023261039336600461209a565b610921565b3480156103a457600080fd5b5061023260008051602061258283398151915281565b3480156103c657600080fd5b506101c06103d5366004612034565b610b9b565b3480156103e657600080fd5b506101c06103f5366004612051565b610c25565b61040d610408366004612051565b610cd8565b6040516101a29190612142565b34801561042657600080fd5b5060015461043f9061010090046001600160a01b031681565b6040516001600160a01b0390911681526020016101a2565b34801561046357600080fd5b5061019661047236600461206a565b6111b4565b34801561048357600080fd5b50610232600081565b34801561049857600080fd5b506101c06104a7366004612155565b6111dd565b3480156104b857600080fd5b506101e26104c7366004612034565b6040805160608082018352600080835260208084018290529284018190526001600160a01b0394851681526005835283812054815260038352839020835191820184528054851682526001810154909416918101919091526002909201549082015290565b34801561053857600080fd5b506001546101969060ff1681565b34801561055257600080fd5b506101c0610561366004612034565b611356565b34801561057257600080fd5b506101c0610581366004612034565b6114a0565b34801561059257600080fd5b506101c06105a136600461206a565b611524565b3480156105b257600080fd5b5060025461043f906001600160a01b031681565b60006001600160e01b03198216637965db0b60e01b14806105f757506301ffc9a760e01b6001600160e01b03198316145b92915050565b33600090815260056020526040812054908190036106365760405162461bcd60e51b815260040161062d90612183565b60405180910390fd5b60015460ff16156106595760405162461bcd60e51b815260040161062d906121d8565b33600090815260056020908152604080832054808452600390925280832060010180546001600160a01b031916905551909182917f2e3f0e8f6904984244368dfff28046157a23abf558feb664bf3727766cbd200c9190a25050565b60408051606081018252600080825260208201819052918101829052906106db83611549565b6040516020016106eb9190612142565b60408051601f1981840301815282825280516020918201206000908152600482528281205481526003825282902060608401835280546001600160a01b0390811685526001820154169184019190915260020154908201529392505050565b60008061075683611549565b6040516020016107669190612142565b60408051601f198184030181529181528151602092830120600090815260049092529020549392505050565b33600090815260056020526040812054908190036107c25760405162461bcd60e51b815260040161062d90612183565b60015460ff16156107e55760405162461bcd60e51b815260040161062d906121d8565b6001600160a01b0382166108515760405162461bcd60e51b815260206004820152602d60248201527f506f7274616c52656769737472793a20636f6e646974696f6e2061646472657360448201526c0732063616e6e6f74206265203609c1b606482015260840161062d565b33600090815260056020908152604080832054808452600390925280832060010180546001600160a01b0319166001600160a01b03871690811790915590519192909183917f50dc6bddd2ee7ed8c2f3a3bc6b995160e945bffd902a4135fccbe2fadbb3320991a3505050565b6000828152602081905260409020600101546108d9816115ac565b6108e383836115b9565b50505050565b6001600160a01b03811633146109125760405163334bd91960e11b815260040160405180910390fd5b61091c828261164b565b505050565b60015460009061010090046001600160a01b03166109515760405162461bcd60e51b815260040161062d90612222565b60015461010090046001600160a01b031633146109805760405162461bcd60e51b815260040161062d9061226d565b60015460ff16156109a35760405162461bcd60e51b815260040161062d906121d8565b600082600001516001600160a01b0316632fcbab9a6040518163ffffffff1660e01b8152600401600060405180830381865afa1580156109e7573d6000803e3d6000fd5b505050506040513d6000823e601f3d908101601f19168201604052610a0f9190810190612312565b90506000610a1c82611549565b604051602001610a2c9190612142565b60408051601f1981840301815291815281516020928301206000818152600490935291205490915015610ac75760405162461bcd60e51b815260206004820152603d60248201527f506f7274616c52656769737472793a20706f7274616c20616c7265616479206560448201527f786973747320666f72207468697320766563746f722061646472657373000000606482015260840161062d565b600660008154610ad6906123fe565b90915550600654600082815260046020908152604080832084905587516001600160a01b0390811684526005835281842085905581516060810183528951821681528084018581528a8501518285019081528787526003909552838620915182549084166001600160a01b031991821617835590516001830180549185169190921617905592516002909301929092558751905191169183917f991e8a89cc0b450dd18d7845eb5952690d2e9b8edb3624d5f5b929f3260782989190a3949350505050565b600080516020612582833981519152610bb3816115ac565b60015460ff1615610bd65760405162461bcd60e51b815260040161062d906121d8565b6001600160a01b038216610bfc5760405162461bcd60e51b815260040161062d90612417565b50600180546001600160a01b0390921661010002610100600160a81b0319909216919091179055565b3360009081526005602052604081205490819003610c555760405162461bcd60e51b815260040161062d90612183565b60015460ff1615610c785760405162461bcd60e51b815260040161062d906121d8565b33600090815260056020908152604080832054808452600383529281902060020185905580518381529182018590527fc45b50c704f83a591e64a45d94b4e274cc467d15386c75d56bef687efe5aea4a91015b60405180910390a1505050565b6002546060906001600160a01b0316610d435760405162461bcd60e51b815260206004820152602760248201527f506f7274616c52656769737472793a20617661746172207265676973747279206044820152661b9bdd081cd95d60ca1b606482015260840161062d565b600254604051632b0fe8e760e21b81523360048201526001600160a01b039091169063ac3fa39c90602401602060405180830381865afa158015610d8b573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610daf919061245f565b610e0c5760405162461bcd60e51b815260206004820152602860248201527f506f7274616c52656769737472793a2063616c6c6572206d7573742062652061604482015267371030bb30ba30b960c11b606482015260840161062d565b60015460ff1615610e2f5760405162461bcd60e51b815260040161062d906121d8565b6000610e3a836116b6565b60e0810151602001519091506001600160a01b031615610f5b5760e08101516020908101519082015160408084015160608501518551925163f610c1d560e01b81526001600160a01b039485166004820152918416602483015283166044820152908216606482015233608482015291169063f610c1d59060a4016020604051808303816000875af1158015610ed4573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610ef8919061245f565b610f5b5760405162461bcd60e51b815260206004820152602e60248201527f506f7274616c52656769737472793a20706f7274616c206a756d7020636f6e6460448201526d1a5d1a5bdb9cc81b9bdd081b595d60921b606482015260840161062d565b60e08101516040015115611036578060e0015160400151341015610fe75760405162461bcd60e51b815260206004820152603960248201527f506f7274616c52656769737472793a20496e73756666696369656e742066656560448201527f20617474616368656420746f206a756d70207265717565737400000000000000606482015260840161062d565b60008160e001516040015134610ffd9190612481565b9050801561103457604051339082156108fc029083906000818181858888f19350505050158015611032573d6000803e3d6000fd5b505b505b60e081015160400151156111055760208082015160e0830151604090810151815160608082018452838701516001600160a01b0390811683529087015181169582019586523382850190815293516354cc5a0b60e01b815291518116600483015294518516602482015291518416604483015292909116916354cc5a0b9160640160006040518083038185885af11580156110d5573d6000803e3d6000fd5b50505050506040513d6000823e601f3d908101601f191682016040526110fe9190810190612494565b9392505050565b6020808201516040805160608082018352828601516001600160a01b0390811683529086015181169482019485523382840190815292516354cc5a0b60e01b81529151811660048301529351841660248201529051831660448201529116906354cc5a0b906064016000604051808303816000875af115801561118c573d6000803e3d6000fd5b505050506040513d6000823e601f3d908101601f191682016040526110fe9190810190612494565b6000918252602082815260408084206001600160a01b0393909316845291905290205460ff1690565b60015461010090046001600160a01b031661120a5760405162461bcd60e51b815260040161062d90612222565b60015461010090046001600160a01b031633146112395760405162461bcd60e51b815260040161062d9061226d565b60015460ff161561125c5760405162461bcd60e51b815260040161062d906121d8565b6001600160a01b038216600090815260056020526040812054908190036112d65760405162461bcd60e51b815260206004820152602860248201527f506f7274616c52656769737472793a206f6c6420657870657269656e6365206e6044820152671bdd08199bdd5b9960c21b606482015260840161062d565b6001600160a01b038281166000818152600560209081526040808320869055938716808352848320839055858352600382529184902080546001600160a01b03191684179055835185815290810191909152918201527f9a2d918555b7a5bdb899957e6683ff4e9c81b8a671ca77d3d0ad0ee78343def790606001610ccb565b60008051602061258283398151915261136e816115ac565b60015460ff16156113915760405162461bcd60e51b815260040161062d906121d8565b6001600160a01b0382166113f65760405162461bcd60e51b815260206004820152602660248201527f506f7274616c52656769737472793a207a65726f2061646472657373206e6f74604482015265081d985b1a5960d21b606482015260840161062d565b6006546040516344efdce560e11b815260048101919091526001600160a01b038316906389dfb9ca90602401600060405180830381600087803b15801561143c57600080fd5b505af1158015611450573d6000803e3d6000fd5b50506001805460ff19168117905550506040516001600160a01b03831681527f5c2aada8346cff55bb7d8df34aadd7c8f457d6e3e14cdaa3c6a03eea86894d009060200160405180910390a15050565b6000805160206125828339815191526114b8816115ac565b60015460ff16156114db5760405162461bcd60e51b815260040161062d906121d8565b6001600160a01b0382166115015760405162461bcd60e51b815260040161062d90612417565b50600280546001600160a01b0319166001600160a01b0392909216919091179055565b60008281526020819052604090206001015461153f816115ac565b6108e3838361164b565b60608160000151826020015183604001516115678560600151611c89565b6115748660800151611c89565b6115818760a00151611c89565b604051602001611596969594939291906124e5565b6040516020818303038152906040529050919050565b6115b68133611d1c565b50565b60006115c583836111b4565b611643576000838152602081815260408083206001600160a01b03861684529091529020805460ff191660011790556115fb3390565b6001600160a01b0316826001600160a01b0316847f2f8788117e7eff1d82e926ec794901d17c78024a50270940304540a733656f0d60405160405180910390a45060016105f7565b5060006105f7565b600061165783836111b4565b15611643576000838152602081815260408083206001600160a01b0386168085529252808320805460ff1916905551339286917ff6391f5c32d9c69d2a47ea670b442974b53935d1edc7fd64eb21e047a839171b9190a45060016105f7565b60408051610100810182526000808252602080830182905282840182905260608084018390526080840183905260a084018390528451808201865283815280830184905280860184905260c08501528451908101855282815280820183905280850183905260e084015283516328b793cf60e11b8152935192933393849263516f279e92600480820193918290030181865afa15801561175a573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061177e9190612564565b90506001600160a01b0381166117f05760405162461bcd60e51b815260206004820152603160248201527f506f7274616c52656769737472793a20617661746172206973206e6f7420696e6044820152701030903b30b634b2103637b1b0ba34b7b760791b606482015260840161062d565b6001600160a01b038116600090815260056020526040812054908190036118895760405162461bcd60e51b815260206004820152604160248201527f506f7274616c52656769737472793a206e6f20706f7274616c20666f756e642060448201527f666f72207468652061766174617227732063757272656e74206c6f636174696f6064820152603760f91b608482015260a40161062d565b8481036118f35760405162461bcd60e51b815260206004820152603260248201527f506f7274616c52656769737472793a2063616e6e6f74206a756d7020746f207460448201527168652073616d6520657870657269656e636560701b606482015260840161062d565b600081815260036020526040902080546001600160a01b0316611980576040805162461bcd60e51b81526020600482015260248101919091527f506f7274616c52656769737472793a20636f756c64206e6f74206d617020637560448201527f7272656e74206c6f636174696f6e20746f20612076616c696420706f7274616c606482015260840161062d565b600086815260036020526040902080546001600160a01b03166119fb5760405162461bcd60e51b815260206004820152602d60248201527f506f7274616c52656769737472793a20696e76616c69642064657374696e617460448201526c1a5bdb881c1bdc9d185b081a59609a1b606482015260840161062d565b604080516101008101825283546001600160a01b039081168083528454909116602080840191909152835163185b3dd560e11b8152845193948501936330b67baa926004808401939192918290030181865afa158015611a5f573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190611a839190612564565b6001600160a01b031681526020018360000160009054906101000a90046001600160a01b03166001600160a01b0316636904c94d6040518163ffffffff1660e01b8152600401602060405180830381865afa158015611ae6573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190611b0a9190612564565b6001600160a01b031681526020018260000160009054906101000a90046001600160a01b03166001600160a01b03166330b67baa6040518163ffffffff1660e01b8152600401602060405180830381865afa158015611b6d573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190611b919190612564565b6001600160a01b031681526020018260000160009054906101000a90046001600160a01b03166001600160a01b0316636904c94d6040518163ffffffff1660e01b8152600401602060405180830381865afa158015611bf4573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190611c189190612564565b6001600160a01b039081168252604080516060808201835287548416825260018089015485166020848101919091526002998a015484860152808701939093528351918201845287548516825287015490931690830152939094015484840152919091019190915295945050505050565b60606000611c9683611d59565b600101905060008167ffffffffffffffff811115611cb657611cb6611e5b565b6040519080825280601f01601f191660200182016040528015611ce0576020820181803683370190505b5090508181016020015b600019016f181899199a1a9b1b9c1cb0b131b232b360811b600a86061a8153600a8504945084611cea57509392505050565b611d2682826111b4565b611d555760405163e2517d3f60e01b81526001600160a01b03821660048201526024810183905260440161062d565b5050565b60008072184f03e93ff9f4daa797ed6e38ed64bf6a1f0160401b8310611d985772184f03e93ff9f4daa797ed6e38ed64bf6a1f0160401b830492506040015b6d04ee2d6d415b85acef81000000008310611dc4576d04ee2d6d415b85acef8100000000830492506020015b662386f26fc100008310611de257662386f26fc10000830492506010015b6305f5e1008310611dfa576305f5e100830492506008015b6127108310611e0e57612710830492506004015b60648310611e20576064830492506002015b600a83106105f75760010192915050565b600060208284031215611e4357600080fd5b81356001600160e01b0319811681146110fe57600080fd5b634e487b7160e01b600052604160045260246000fd5b60405160c0810167ffffffffffffffff81118282101715611e9457611e94611e5b565b60405290565b604051601f8201601f1916810167ffffffffffffffff81118282101715611ec357611ec3611e5b565b604052919050565b600067ffffffffffffffff821115611ee557611ee5611e5b565b50601f01601f191660200190565b600082601f830112611f0457600080fd5b8135611f17611f1282611ecb565b611e9a565b818152846020838601011115611f2c57600080fd5b816020850160208301376000918101602001919091529392505050565b600060208284031215611f5b57600080fd5b813567ffffffffffffffff80821115611f7357600080fd5b9083019060c08286031215611f8757600080fd5b611f8f611e71565b823582811115611f9e57600080fd5b611faa87828601611ef3565b825250602083013582811115611fbf57600080fd5b611fcb87828601611ef3565b602083015250604083013582811115611fe357600080fd5b611fef87828601611ef3565b604083015250606083013560608201526080830135608082015260a083013560a082015280935050505092915050565b6001600160a01b03811681146115b657600080fd5b60006020828403121561204657600080fd5b81356110fe8161201f565b60006020828403121561206357600080fd5b5035919050565b6000806040838503121561207d57600080fd5b82359150602083013561208f8161201f565b809150509250929050565b6000604082840312156120ac57600080fd5b6040516040810181811067ffffffffffffffff821117156120cf576120cf611e5b565b60405282356120dd8161201f565b81526020928301359281019290925250919050565b60005b8381101561210d5781810151838201526020016120f5565b50506000910152565b6000815180845261212e8160208601602086016120f2565b601f01601f19169290920160200192915050565b6020815260006110fe6020830184612116565b6000806040838503121561216857600080fd5b82356121738161201f565b9150602083013561208f8161201f565b60208082526035908201527f506f7274616c52656769737472793a2063616c6c6572206973206e6f742061206040820152747265676973746572656420657870657269656e636560581b606082015260800190565b6020808252602a908201527f506f7274616c52656769737472793a20636f6e747261637420686173206265656040820152691b881d5c19dc9859195960b21b606082015260800190565b6020808252602b908201527f506f7274616c52656769737472793a20657870657269656e636520726567697360408201526a1d1c9e481b9bdd081cd95d60aa1b606082015260800190565b60208082526035908201527f506f7274616c52656769737472793a2063616c6c6572206973206e6f742074686040820152746520657870657269656e636520726567697374727960581b606082015260800190565b60006122d0611f1284611ecb565b90508281528383830111156122e457600080fd5b6110fe8360208301846120f2565b600082601f83011261230357600080fd5b6110fe838351602085016122c2565b60006020828403121561232457600080fd5b815167ffffffffffffffff8082111561233c57600080fd5b9083019060c0828603121561235057600080fd5b612358611e71565b82518281111561236757600080fd5b612373878286016122f2565b82525060208301518281111561238857600080fd5b612394878286016122f2565b6020830152506040830151828111156123ac57600080fd5b6123b8878286016122f2565b604083015250606083015160608201526080830151608082015260a083015160a082015280935050505092915050565b634e487b7160e01b600052601160045260246000fd5b600060018201612410576124106123e8565b5060010190565b60208082526028908201527f506f7274616c52656769737472793a20696e76616c6964207265676973747279604082015267206164647265737360c01b606082015260800190565b60006020828403121561247157600080fd5b815180151581146110fe57600080fd5b818103818111156105f7576105f76123e8565b6000602082840312156124a657600080fd5b815167ffffffffffffffff8111156124bd57600080fd5b8201601f810184136124ce57600080fd5b6124dd848251602084016122c2565b949350505050565b6000875160206124f88285838d016120f2565b88519184019161250b8184848d016120f2565b885192019161251d8184848c016120f2565b875192019161252f8184848b016120f2565b86519201916125418184848a016120f2565b855192019161255381848489016120f2565b919091019998505050505050505050565b60006020828403121561257657600080fd5b81516110fe8161201f56fea49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775a26469706673582212201ae3c1d002779c1dff476e74e2c6f21ee12c2802400b24bb0f707cf87bb1454764736f6c63430008180033a49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775";

type PortalRegistryConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: PortalRegistryConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class PortalRegistry__factory extends ContractFactory {
  constructor(...args: PortalRegistryConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override getDeployTransaction(
    mainAdmin: AddressLike,
    admins: AddressLike[],
    overrides?: NonPayableOverrides & { from?: string }
  ): Promise<ContractDeployTransaction> {
    return super.getDeployTransaction(mainAdmin, admins, overrides || {});
  }
  override deploy(
    mainAdmin: AddressLike,
    admins: AddressLike[],
    overrides?: NonPayableOverrides & { from?: string }
  ) {
    return super.deploy(mainAdmin, admins, overrides || {}) as Promise<
      PortalRegistry & {
        deploymentTransaction(): ContractTransactionResponse;
      }
    >;
  }
  override connect(runner: ContractRunner | null): PortalRegistry__factory {
    return super.connect(runner) as PortalRegistry__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): PortalRegistryInterface {
    return new Interface(_abi) as PortalRegistryInterface;
  }
  static connect(
    address: string,
    runner?: ContractRunner | null
  ): PortalRegistry {
    return new Contract(address, _abi, runner) as unknown as PortalRegistry;
  }
}
