// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// --- TASK ---
// Get funds from users
// Withraw the funds
// Set a Minimum funding value in USD

// This import enables us obtain price feed from chainlink
import { AggregatorV3Interface } from "@chainlink/contracts@0.8.0/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
// import { AggregatorV3Interface } from "./AggregatorV3Interface.sol";

contract FundMe {

    // Since ETH is equivalent to 1e18, we give our minimumUSD 18 zeros as well
    uint256 public minimumUsd = 5e18;

    // A list of addresses to keep track of funders
    address[] public funders;

    function fund() public payable {
        // allow users to send $
        // set a minimum amount a user can send
        // 1. How do we send ETH to this contract?
        //  We make the function payable so that is can send ETH
        require(getConversionRate(msg.value) > minimumUsd, "didn't send enough ETH"); // 1e18 = 1ETH
        // Include this address in the list of funders
        funders.push(msg.sender);
    }

    // Create a function that gets the price of the token
    function getPrice() public view returns (uint256) {
        // Get the Address and ABI of the Contract the stores the price of ETH
        // on ChainLink website. From Sepolia TestNet we have
        // Address 0x694AA1769357215DE4FAC081bf1f309aDC325306 
        // ABI 
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // The 'latestRoundData' method returns five values. 
        // However, we are only interested in 'price'
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // price of ETH in terms of USD
        // We employ a technique call type-casting to change a variable type
        // from int256 to uint256
        return uint256(price * 1e10);
    }

    // Create a function the converts the 'msg.value' base on the price
    function getConversionRate(uint ethAmount) public view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethAmount * ethPrice)/ 1e18;
        return ethAmountInUsd;

    }

    //
    function getVersion() public view returns (uint256){
        return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
    }
    
    //function withdraw() public {}

}
