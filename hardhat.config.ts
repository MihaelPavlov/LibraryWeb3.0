import { HardhatUserConfig, task, subtask } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-etherscan";

const lazyImport = async (module: any) => {
  return await import(module);
};


task("deployToGoerly", "Deploys book library")
.setAction(async () => {
   const { main } = await lazyImport("./scripts/deploy-library");
  
});

subtask("print", "Prints a message")
  .addParam("message", "The message to print")
  .setAction(async (taskArgs) => {
    console.log(taskArgs.message);
  });

  const INFURA_URL = "https://goerli.infura.io/v3/31d722098d4e48929c96519ba339b2d0";

  const PRIVATE_KEY = "a61ded91802937b4690567a62077f2cca4cb1342a9be3cd69fd81689ad349c04";
  
  const config: HardhatUserConfig = {
    solidity: "0.8.17",
    networks: {
      goerli : { 
        url: INFURA_URL,
        accounts: [`0x${PRIVATE_KEY}`],
       }
     },
    etherscan: {
      // Your API key for Etherscan
      // Obtain one at <https://etherscan.io/>
      apiKey: "G4CGACRC745N78HXCWCC4VTXTS9A9HVIXQ "
    }
  };

export default config;
