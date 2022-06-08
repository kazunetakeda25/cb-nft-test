require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-web3");
require("@nomiclabs/hardhat-etherscan");

const dotenv = require('dotenv');
dotenv.config();

const PRIVATE_KEY_RINKEBY = process.env.PRIVATE_KEY_RINKEBY || null;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;
const INFURA_PROJECT_ID = process.env.INFURA_PROJECT_ID;

module.exports = {
  solidity: {
    version: "0.8.12",
    settings: {
      optimizer: {
        enabled: true,
        runs: 10000,
      },
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${INFURA_PROJECT_ID}`,
      accounts: [`0x${PRIVATE_KEY_RINKEBY}`],
      gas: 10000000,
      gasPrice: 30000000000,
      skipDryRun: true,
      networkCheckTimeout: 100000000,
      timeoutBlocks: 200,
    },
  }
};
