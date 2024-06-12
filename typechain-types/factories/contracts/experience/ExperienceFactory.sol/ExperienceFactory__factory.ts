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
  ExperienceFactory,
  ExperienceFactoryInterface,
} from "../../../../contracts/experience/ExperienceFactory.sol/ExperienceFactory";

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
        internalType: "address",
        name: "oldRegistry",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "newRegistry",
        type: "address",
      },
    ],
    name: "AuthorizedRegistryChanged",
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
        internalType: "address",
        name: "owner",
        type: "address",
      },
      {
        internalType: "string",
        name: "_name",
        type: "string",
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
        name: "va",
        type: "tuple",
      },
      {
        internalType: "bytes",
        name: "initData",
        type: "bytes",
      },
    ],
    name: "createExperience",
    outputs: [
      {
        internalType: "address",
        name: "proxy",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
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
        internalType: "address",
        name: "query",
        type: "address",
      },
    ],
    name: "isClone",
    outputs: [
      {
        internalType: "bool",
        name: "result",
        type: "bool",
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
        name: "_registry",
        type: "address",
      },
    ],
    name: "setAuthorizedRegistry",
    outputs: [],
    stateMutability: "nonpayable",
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
    name: "setImplementation",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_proxyImplementation",
        type: "address",
      },
    ],
    name: "setProxyImplementation",
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
    inputs: [],
    name: "supportsVersion",
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
        name: "exp",
        type: "address",
      },
      {
        internalType: "bytes",
        name: "initData",
        type: "bytes",
      },
    ],
    name: "upgradeExperience",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;

const _bytecode =
  "0x60806040523480156200001157600080fd5b5060405162001408380380620014088339810160408190526200003491620002a6565b81816001600160a01b038216620000a95760405162461bcd60e51b815260206004820152602e60248201527f42617365466163746f72793a206d61696e2061646d696e2063616e6e6f74206260448201526d65207a65726f206164647265737360901b60648201526084015b60405180910390fd5b620000b6600083620001c4565b50620000d2600080516020620013e883398151915283620001c4565b5060005b8151811015620001b95760006001600160a01b03168282815181106200010057620001006200038f565b60200260200101516001600160a01b031603620001725760405162461bcd60e51b815260206004820152602960248201527f42617365466163746f72793a2061646d696e2063616e6e6f74206265207a65726044820152686f206164647265737360b81b6064820152608401620000a0565b620001af600080516020620013e88339815191528383815181106200019b576200019b6200038f565b6020026020010151620001c460201b60201c565b50600101620000d6565b5050505050620003a5565b6000828152602081815260408083206001600160a01b038516845290915281205460ff1662000269576000838152602081815260408083206001600160a01b03861684529091529020805460ff19166001179055620002203390565b6001600160a01b0316826001600160a01b0316847f2f8788117e7eff1d82e926ec794901d17c78024a50270940304540a733656f0d60405160405180910390a45060016200026d565b5060005b92915050565b80516001600160a01b03811681146200028b57600080fd5b919050565b634e487b7160e01b600052604160045260246000fd5b60008060408385031215620002ba57600080fd5b620002c58362000273565b602084810151919350906001600160401b0380821115620002e557600080fd5b818601915086601f830112620002fa57600080fd5b8151818111156200030f576200030f62000290565b8060051b604051601f19603f8301168101818110858211171562000337576200033762000290565b6040529182528482019250838101850191898311156200035657600080fd5b938501935b828510156200037f576200036f8562000273565b845293850193928501926200035b565b8096505050505050509250929050565b634e487b7160e01b600052603260045260246000fd5b61103380620003b56000396000f3fe608060405234801561001057600080fd5b50600436106100ff5760003560e01c80639fdcd3a411610097578063d547741f11610066578063d547741f14610226578063d784d42614610239578063db70a6931461024c578063e921c2751461025f57600080fd5b80639fdcd3a4146101d3578063a217fddf146101e6578063aaf10f42146101ee578063c9dd1eea1461021357600080fd5b80632f2ff15d116100d35780632f2ff15d1461018557806336568abe1461019857806375b238fc146101ab57806391d14854146101c057600080fd5b8062ae36761461010457806301ffc9a71461012c578063090741a01461013f578063248a9ca314610154575b600080fd5b610117610112366004610ada565b610267565b60405190151581526020015b60405180910390f35b61011761013a366004610afc565b6102dc565b61015261014d366004610ada565b610313565b005b610177610162366004610b26565b60009081526020819052604090206001015490565b604051908152602001610123565b610152610193366004610b3f565b6103e9565b6101526101a6366004610b3f565b610414565b610177600080516020610fde83398151915281565b6101176101ce366004610b3f565b61044c565b6101526101e1366004610ada565b610475565b610177600081565b6001546001600160a01b03165b6040516001600160a01b039091168152602001610123565b6101fb610221366004610c80565b61052c565b610152610234366004610b3f565b610659565b610152610247366004610ada565b61067e565b61015261025a366004610db6565b61072a565b610177600181565b600080600160009054906101000a90046001600160a01b031660601b905060405169363d3d373d3d3d363d7360b01b815281600a8201526e5af43d82803e903d91602b57fd5bf360881b601e82015260408101602d600082873c600d810151600d830151148151835114169350505050919050565b60006001600160e01b03198216637965db0b60e01b148061030d57506301ffc9a760e01b6001600160e01b03198316145b92915050565b600080516020610fde83398151915261032b8161083b565b6001600160a01b03821661039c5760405162461bcd60e51b815260206004820152602d60248201527f576f726c64466163746f72793a2072656769737472792063616e6e6f7420626560448201526c207a65726f206164647265737360981b60648201526084015b60405180910390fd5b600380546001600160a01b0319166001600160a01b03841690811790915560405181907fc86b12484784843e0f58748ffb8c87f7ee384e04382a190867f3cccc3b6cf97b90600090a35050565b6000828152602081905260409020600101546104048161083b565b61040e8383610848565b50505050565b6001600160a01b038116331461043d5760405163334bd91960e11b815260040160405180910390fd5b61044782826108da565b505050565b6000918252602082815260408084206001600160a01b0393909316845291905290205460ff1690565b600080516020610fde83398151915261048d8161083b565b6001600160a01b0382166105095760405162461bcd60e51b815260206004820152603860248201527f42617365466163746f72793a2070726f787920696d706c656d656e746174696f60448201527f6e2063616e6e6f74206265207a65726f206164647265737300000000000000006064820152608401610393565b50600280546001600160a01b0319166001600160a01b0392909216919091179055565b6003546000906001600160a01b03166105575760405162461bcd60e51b815260040161039390610e09565b6003546001600160a01b031633146105815760405162461bcd60e51b815260040161039390610e51565b610589610945565b600154604051639c02006160e01b81526001600160a01b039182166004820152919250821690639c02006190602401600060405180830381600087803b1580156105d257600080fd5b505af11580156105e6573d6000803e3d6000fd5b5050604051630fad94ff60e41b81526001600160a01b038416925063fad94ff0915061061e9089908990899089908990600401610f0e565b600060405180830381600087803b15801561063857600080fd5b505af115801561064c573d6000803e3d6000fd5b5050505095945050505050565b6000828152602081905260409020600101546106748161083b565b61040e83836108da565b600080516020610fde8339815191526106968161083b565b6001600160a01b0382166107075760405162461bcd60e51b815260206004820152603260248201527f42617365466163746f72793a20696d706c656d656e746174696f6e2063616e6e6044820152716f74206265207a65726f206164647265737360701b6064820152608401610393565b50600180546001600160a01b0319166001600160a01b0392909216919091179055565b6003546001600160a01b03166107525760405162461bcd60e51b815260040161039390610e09565b6003546001600160a01b0316331461077c5760405162461bcd60e51b815260040161039390610e51565b604051632663d1f760e01b81526001600160a01b0384166004820181905290632663d1f790602401600060405180830381600087803b1580156107be57600080fd5b505af11580156107d2573d6000803e3d6000fd5b5050604051631377d1f560e21b81526001600160a01b0386169250634ddf47d491506108049085908590600401610fc1565b600060405180830381600087803b15801561081e57600080fd5b505af1158015610832573d6000803e3d6000fd5b50505050505050565b61084581336109cc565b50565b6000610854838361044c565b6108d2576000838152602081815260408083206001600160a01b03861684529091529020805460ff1916600117905561088a3390565b6001600160a01b0316826001600160a01b0316847f2f8788117e7eff1d82e926ec794901d17c78024a50270940304540a733656f0d60405160405180910390a450600161030d565b50600061030d565b60006108e6838361044c565b156108d2576000838152602081815260408083206001600160a01b0386168085529252808320805460ff1916905551339286917ff6391f5c32d9c69d2a47ea670b442974b53935d1edc7fd64eb21e047a839171b9190a450600161030d565b6002546000906001600160a01b03166109b25760405162461bcd60e51b815260206004820152602960248201527f42617365466163746f72793a2070726f787920696d706c656d656e746174696f6044820152681b881b9bdd081cd95d60ba1b6064820152608401610393565b6002546109c7906001600160a01b0316610a09565b905090565b6109d6828261044c565b610a055760405163e2517d3f60e01b81526001600160a01b038216600482015260248101839052604401610393565b5050565b60006001600160a01b038216610a6d5760405162461bcd60e51b815260206004820152602360248201527f42617365466163746f72793a20696d706c656d656e746174696f6e206e6f74206044820152621cd95d60ea1b6064820152608401610393565b60008260601b9050604051733d602d80600a3d3981f3363d3d373d3d3d363d7360601b81528160148201526e5af43d82803e903d91602b57fd5bf360881b60288201526037816000f0949350505050565b80356001600160a01b0381168114610ad557600080fd5b919050565b600060208284031215610aec57600080fd5b610af582610abe565b9392505050565b600060208284031215610b0e57600080fd5b81356001600160e01b031981168114610af557600080fd5b600060208284031215610b3857600080fd5b5035919050565b60008060408385031215610b5257600080fd5b82359150610b6260208401610abe565b90509250929050565b634e487b7160e01b600052604160045260246000fd5b60405160c0810167ffffffffffffffff81118282101715610ba457610ba4610b6b565b60405290565b600082601f830112610bbb57600080fd5b813567ffffffffffffffff80821115610bd657610bd6610b6b565b604051601f8301601f19908116603f01168101908282118183101715610bfe57610bfe610b6b565b81604052838152866020858801011115610c1757600080fd5b836020870160208301376000602085830101528094505050505092915050565b60008083601f840112610c4957600080fd5b50813567ffffffffffffffff811115610c6157600080fd5b602083019150836020828501011115610c7957600080fd5b9250929050565b600080600080600060808688031215610c9857600080fd5b610ca186610abe565b9450602086013567ffffffffffffffff80821115610cbe57600080fd5b610cca89838a01610baa565b95506040880135915080821115610ce057600080fd5b9087019060c0828a031215610cf457600080fd5b610cfc610b81565b823582811115610d0b57600080fd5b610d178b828601610baa565b825250602083013582811115610d2c57600080fd5b610d388b828601610baa565b602083015250604083013582811115610d5057600080fd5b610d5c8b828601610baa565b604083015250606083013560608201526080830135608082015260a083013560a0820152809550506060880135915080821115610d9857600080fd5b50610da588828901610c37565b969995985093965092949392505050565b600080600060408486031215610dcb57600080fd5b610dd484610abe565b9250602084013567ffffffffffffffff811115610df057600080fd5b610dfc86828701610c37565b9497909650939450505050565b60208082526028908201527f42617365466163746f72793a20617574686f72697a6564207265676973747279604082015267081b9bdd081cd95d60c21b606082015260800190565b6020808252602e908201527f42617365466163746f72793a2063616c6c6572206973206e6f7420617574686f60408201526d72697a656420726567697374727960901b606082015260800190565b6000815180845260005b81811015610ec557602081850181015186830182015201610ea9565b506000602082860101526020601f19601f83011685010191505092915050565b81835281816020850137506000828201602090810191909152601f909101601f19169091010190565b6001600160a01b0386168152608060208201819052600090610f3290830187610e9f565b8281036040840152855160c08252610f4d60c0830182610e9f565b905060208701518282036020840152610f668282610e9f565b91505060408701518282036040840152610f808282610e9f565b915050606087015160608301526080870151608083015260a087015160a08301528381036060850152610fb4818688610ee5565b9998505050505050505050565b602081526000610fd5602083018486610ee5565b94935050505056fea49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775a2646970667358221220fdc66a47c677af62ee08fc94c315f83bc2626387936be3a121a4da90f5011aa864736f6c63430008180033a49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775";

type ExperienceFactoryConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: ExperienceFactoryConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class ExperienceFactory__factory extends ContractFactory {
  constructor(...args: ExperienceFactoryConstructorParams) {
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
      ExperienceFactory & {
        deploymentTransaction(): ContractTransactionResponse;
      }
    >;
  }
  override connect(runner: ContractRunner | null): ExperienceFactory__factory {
    return super.connect(runner) as ExperienceFactory__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): ExperienceFactoryInterface {
    return new Interface(_abi) as ExperienceFactoryInterface;
  }
  static connect(
    address: string,
    runner?: ContractRunner | null
  ): ExperienceFactory {
    return new Contract(address, _abi, runner) as unknown as ExperienceFactory;
  }
}