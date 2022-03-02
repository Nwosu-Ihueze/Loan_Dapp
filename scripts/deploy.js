const { ethers } = require("hardhat");
const { LOAN_TOKEN, TERMS} = require("../constants");
require("dotenv").config({ path: ".env" });



async function main() {
  
  // const terms = terms;
  const contractAddress = LOAN_TOKEN;
  const LoanTerms = TERMS;

  const loanContract = await ethers.getContractFactory("Loan");

  
  const deployedLoanContract = await loanContract.deploy(
     contractAddress, LoanTerms
  );
  await deployedLoanContract.deployed();

  
  console.log("Loan Contract Address:", deployedLoanContract.address);
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });