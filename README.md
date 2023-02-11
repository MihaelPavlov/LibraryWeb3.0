# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts
```

# Verify Library Contract

Deploy library contract on live network:
command -> npx hardhat run scripts/deploy-library.ts --network networkName

Verify directly on etherscan: 
command -> npx hardhat verify-etherscan --network networkName --contract-address contractAddress

Verified contract on Goerli:
https://goerli.etherscan.io/address/0xB115936fab293142C8E18781A8D5Aa264fAF5912#code

Verified contract on Sepolia:
https://sepolia.etherscan.io/address/0xcAd5F3DCbE7F17396e775BA81C031e2ED714782c#code
