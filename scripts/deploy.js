const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });



async function main() {
  
  const loanContract = await ethers.getContractFactory("Loan");

  
  const deployedLoanContract = await loanContract.deploy();
  await deployedLoanContract.deployed();

  
  console.log("Loan Contract Address:", deployedLoanContract.address);

  
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });