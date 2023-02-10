import { ethers } from "hardhat";

export async function main() {  
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contracts with the account ${deployer.address}`)

  const balance = await deployer.getBalance();
  console.log(`Account balance: ${balance.toString()}`);
  
  const Book_Library_Factory = await ethers.getContractFactory("BookLibrary");
  const bookLibrary = await Book_Library_Factory.deploy();
  
  console.log(`The Library contract is deployed to ${bookLibrary.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});