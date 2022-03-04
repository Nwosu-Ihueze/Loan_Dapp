// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Loan {
  address payable public lender;
  address payable public borrower;
  address public owner;
    
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

    constructor() {
        owner = msg.sender;
    }

    function LoanRequest() public onlyInStage(LoanStage.Requested)
    {
        stage = LoanStage.Accepted;
        ERC20(owner).transferFrom(
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
        ERC20(owner).transfer(
            borrower,
            terms.loanAmount
        );
        emit LoanRequestAccepted(owner);
    }

    function repayAmount() public payable onlyInStage(LoanStage.Repaid) {
      require(msg.sender == borrower);
      require(msg.value == terms.loanAmount + terms.collateralAmount);
      ERC20(owner).transferFrom(borrower, lender, terms.loanAmount + terms.collateralAmount);
    }

    event LoanPaid();
    function payLoan() public payable onlyInStage(LoanStage.Repaid) {
        require(block.timestamp <= terms.dueDate);
        require(msg.value == terms.loanAmount + terms.collateralAmount);

        if (block.timestamp <= terms.dueDate) {
        ERC20(owner).transferFrom(
            borrower,
            lender,
            terms.loanAmount + terms.collateralAmount
        );
         emit LoanPaid();
        selfdestruct(borrower);
        }
        else 
        return;
    }

    function repossess() public onlyInStage(LoanStage.Repossessed) {
        require(block.timestamp > terms.dueDate);
        ERC20(owner).transferFrom(
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