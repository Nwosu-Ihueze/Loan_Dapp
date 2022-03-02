// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Loan {
  address payable public lender;
  address payable public borrower;
  address public contractAddress;
    
    struct Terms {
      uint loanAmount;
      uint collateralAmount;
      uint payoffAmount;
      uint loanDuration;
      uint dueDate;
    }

    Terms public terms;
    
    enum LoanStage {
      Requested, Accepted, Repaid, Repossessed, Withdraw
    }

    LoanStage public stage;

    modifier onlyInStage(LoanStage expectedStage) {
        require(stage == expectedStage,
        "Operation not allowed"
        );
        _;
    }

    constructor(Terms memory _terms, address _contractAddress) {
        terms = _terms;
        contractAddress = _contractAddress;
        lender = payable(msg.sender);
        stage = LoanStage.Requested;
    }

    function LoanRequest() public onlyInStage(LoanStage.Requested)
    {
        stage = LoanStage.Accepted;
        ERC20(contractAddress).transferFrom(
            msg.sender,
            address(this),
            terms.loanAmount
        ); 
    }
    event LoanRequestAccepted(address contractAddress);

    function lendEther() public payable onlyInStage(LoanStage.Accepted) {
        require(msg.value == terms.loanAmount);
        borrower = payable(msg.sender);
        stage = LoanStage.Repaid;
        ERC20(contractAddress).transfer(
            borrower,
            terms.loanAmount
        );
        emit LoanRequestAccepted(contractAddress);
    }

    event LoanPaid();
    function payLoan() public payable onlyInStage(LoanStage.Repaid) {
        require(block.timestamp <= terms.dueDate);
        require(msg.value == terms.payoffAmount);
        ERC20(contractAddress).transferFrom(
            borrower,
            lender,
            terms.collateralAmount
        );
         emit LoanPaid();
        selfdestruct(borrower);
    }

    function repossess() public onlyInStage(LoanStage.Repossessed) {
        require(block.timestamp > terms.dueDate);
        ERC20(contractAddress).transferFrom(
            borrower,
            lender,
            terms.collateralAmount
        );
        
        selfdestruct(lender);
    }
    function withdraw() public onlyInStage(LoanStage.Withdraw) {
        require(msg.sender == lender);
        require(block.timestamp > terms.dueDate);
        
        selfdestruct(lender);
    }
}