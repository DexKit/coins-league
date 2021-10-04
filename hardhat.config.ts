import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";
import "hardhat-gas-reporter";

import "hardhat-deploy-ethers";
import "hardhat-deploy";
//import "@symfoni/hardhat-react";
//import "hardhat-typechain";
import "hardhat-contract-sizer";

import * as dotenv from "dotenv";

dotenv.config();

const { ALCHEMY_API, PRIVATE_KEY } = process.env;
// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
export default {
  react: {
    providerPriority: ["web3modal", "hardhat"],
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: true,
    disambiguatePaths: false,
  },
  solidity: {
    compilers: [
      {
        version: "0.8.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.6.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  networks: {
    hardhat: {
      forking: {
        url: `https://eth-mainnet.alchemyapi.io/v2/${ALCHEMY_API}`,
        blockNumber: 12956195,
      },
    },
    mumbai: {
      url: "https://rpc-mumbai.maticvigil.com",
      gasPrice: 8000000000,
      accounts: [PRIVATE_KEY],
    },
    matic: {
      url: `https://polygon-rpc.com/`,
      accounts: [PRIVATE_KEY],
      gasPrice: 8000000000,
    },
  },
  gasReporter: {
    enabled: true,
  },
  mocha: {
    timeout: 2000000,
  },
};