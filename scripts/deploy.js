async function main() {
    const [deployer] = await ethers.getSigners();
    
    console.log("Deploying contracts with the account:", deployer.address);
    // console.log("Account balance:", (await deployer.getBalance()).toString());
    
    // Get the ContractFactory for your contract
    const MyContract = await ethers.getContractFactory("AIstronaut");
    
    // Deploy the contract
    const myContract = await MyContract.deploy("0xc886E3974Eb90B44AB91e13e5F46A085d8cF150D");
    
    // Wait for deployment to finish
    await myContract.waitForDeployment();
    
    console.log("Contract deployed to:", await myContract.getAddress());
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });