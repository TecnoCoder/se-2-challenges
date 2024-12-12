// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  bool public openForWithdraw = true;

  uint256 public constant threshold = 1 ether;

  uint256 public deadline = block.timestamp + 30 seconds;
  
  mapping(address => uint256) public balances;

  event Stake(address  staker, uint256 amount);
  event Withdraw(address withdrawer, uint256 amount);
  event Execute(address executer, uint256 totalStaked);

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)

function stake() public payable {
    require(msg.value > 0, "Insuficient Funds");
    require(block.timestamp < deadline,"The time to stake gone!");

      balances[msg.sender] += msg.value;

      emit Stake(msg.sender, msg.value);
}

  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
      function execute() public {

       require(
        block.timestamp > deadline,
        "The execution time has not yet been reached"
        ); 

       if (address(this).balance >= threshold){
        exampleExternalContract.complete{value: address(this).balance }();
        openForWithdraw = false;
        emit Execute(msg.sender, address(this).balance);
        }  
      }

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  function withdraw() public {
    require(openForWithdraw == true, "It's closed to Withdraw");
    require(block.timestamp > deadline, "The time for withdraw, NOT is this moment!!!");
    require(address(this).balance < threshold, "The money isn't completed" );
    require(balances[msg.sender] > 0, "You don't have money to withdraw!!!");

    uint256 amount = balances[msg.sender];
    balances[msg.sender] = 0;

    (bool response, /*bytes memory data */) = msg.sender.call{value:  /*amount*/ amount}("");

    require(response, "Transaction Error");

    emit Withdraw(msg.sender, balances[msg.sender]);


  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
function timeLeft() public view returns (uint256) {
  if(block.timestamp < deadline) {
    return deadline - block.timestamp;
  } else 
    return 0;
  }
    // Add the `receive()` special function that receives eth and calls stake()
receive() external payable {
  stake();
 }

}
