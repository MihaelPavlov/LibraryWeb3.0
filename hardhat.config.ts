import { HardhatUserConfig, task, subtask, types } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-etherscan";
require('dotenv').config();

const { INFURA_URL_GOERLI, INFURA_URL_SEPOLIA, PRIVATE_KEY, ETHERSCAN_KEY } = process.env;

task("verify-etherscan", "Verify deployed contract on Etherscan")
  .addParam("contractAddress", "Contract address deployed", undefined, types.string)
  .setAction(async ({ contractAddress }: { contractAddress: string }, hre) => {
    try {

      await hre.run("verify:verify", {
        address: contractAddress,
        contract: 'contracts/BookLibrary.sol:BookLibrary' // <path-to-contract>:<contract-name>
      });

      await hre.run('print', { message: `Deployed` })
    } catch ({ message }) {
      await hre.run('print', { message: `Error: ${message}` })
    }
  })

subtask("print", "Prints a message")
  .addParam("message", "The message to print")
  .setAction(async (taskArgs) => {
    console.log(taskArgs.message);
  });

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: INFURA_URL_GOERLI,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    sepolia: {
      url: INFURA_URL_SEPOLIA,
      accounts: [`0x${PRIVATE_KEY}`],
    }
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at <https://etherscan.io/>
    apiKey: ETHERSCAN_KEY
  }
};

export default config;
