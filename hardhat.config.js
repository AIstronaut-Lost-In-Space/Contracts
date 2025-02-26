require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const PRIVATE_KEY = process.env.PRIVATE_KEY || "0x0000000000000000000000000000000000000000000000000000000000000000";
// Optional: Add an Alchemy or Infura API key if you want a dedicated RPC endpoint
// const SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL;

module.exports = {
  solidity: "0.8.20",
  networks: {
    // sepolia: {
    //   url: SEPOLIA_RPC_URL,
    //   accounts: [PRIVATE_KEY],
    //   chainId: 11155111, 
    // }
    liskSepolia: {
      url: "https://rpc.sepolia-api.lisk.com", // Replace with official Lisk Sepolia RPC URL
      accounts: [PRIVATE_KEY],
      chainId: 4202, // Replace with actual Lisk Sepolia chain ID
      gasPrice: 20000000000,
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY // For contract verification
  }
};