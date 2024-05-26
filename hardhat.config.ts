import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require("dotenv").config();

const throwError = (name: string) => {
  throw new Error(`Missing environment variable: ${name}`);
}

const dk = process.env.DEPLOYMENT_KEY;
const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      outputSelection: {
        "*": {
          "*": ["metadata", "evm.bytecode", "evm.deployedBytecode", "abi"],
          "": ["ast"],
        },
      },
    },
  },
  defaultNetwork: 'hardhat',
  etherscan: {
    apiKey: {
      baseSepolia: process.env.BASE_SEPOLIA_API_KEY || throwError('BASE_SEPOLIA_API_KEY'),
      
    },
    customChains: [
      {
        network: "baseSepolia",
        chainId: 84532,
        urls: {
          apiURL: 'https://sepolia.basescan.org/api',
          browserURL: 'https://sepolia.basescan.org',
        }
      }
    ],
  },
  networks: {
    hardhat: {
      chainId: 55555,
      /*forking: {
        url: 'https://sepolia.base.org',
      },*/
    },
    xrdna_testnet: {
      chainId: 26379,
      url: 'https://rpc-xrdna-testnet-s1zvdnqr3d.t.conduit.xyz',
    },
    base_sepolia: {
      chainId: 84532,
      /*forking: {
        url: 'https://sepolia.base.org',
      },*/
      url: 'https://sepolia.base.org',
      accounts: dk ? [dk]: undefined
    },
  },
  gasReporter: { gasPrice: 0.3, enabled: true },
};

export default config;
