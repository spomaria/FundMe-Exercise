// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// --- TASK ---
// Get funds from users
// Withraw the funds
// Set a Minimum funding value in USD

// This named import enables us use the functionalities of the 
// PriceConverter library
import { PriceConverter } from "./PriceConverter.sol";

contract FundMe {

    // This command will enable all variables of type uint256 to access the 
    // methods in the PriceConverter library
    using PriceConverter for uint256;

    // Since ETH is equivalent to 1e18, we give our minimumUSD 18 zeros as well
    uint256 public minimumUsd = 5e18;

    // A list of addresses to keep track of funders
    address[] public funders;
    mapping (address funders => uint256 amountFunded) public addressToAmountFunded;

    function fund() public payable {
        // allow users to send $
        // set a minimum amount a user can send
        // 1. How do we send ETH to this contract?
        //  We make the function payable so that is can send ETH
        require(msg.value.getConversionRate() > minimumUsd, "didn't send enough ETH"); // 1e18 = 1ETH
        // Include this address in the list of funders
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value;
    }

    
    //function withdraw() public {}

}
