require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("@nomicfoundation/hardhat-verify");
const PRIVATE_KEY = process.env.PRIVATE_KEY || "0x0000000000000000000000000000000000000000000000000000000000000000";
module.exports = {
  solidity: "0.8.20",
  networks: {
    // sepolia: {
    //   url: SEPOLIA_RPC_URL,
    //   accounts: [PRIVATE_KEY],
    //   chainId: 11155111, 
    // }
    // liskSepolia: {
    //   url: "https://rpc.sepolia-api.lisk.com", // Replace with official Lisk Sepolia RPC URL
    //   accounts: [PRIVATE_KEY],
    //   chainId: 4202, // Replace with actual Lisk Sepolia chain ID
    //   gasPrice: 20000000000,
    // }
    mantle: {
      url: "https://rpc.sepolia.mantle.xyz",
      accounts: [PRIVATE_KEY],
      chainId: 5003, // Correct Mantle Testnet chain ID
       // Increase gas limit
    },
  },
  etherscan: {
    apiKey: {
      'mantle-sepolia': 'empty'
    },
    customChains: [
      {
        network: "mantle-sepolia",
        chainId: 5003,
        urls: {
          apiURL: "https://explorer.sepolia.mantle.xyz:443/api",
          browserURL: "https://explorer.sepolia.mantle.xyz"
        }
      }
    ]
  }
};