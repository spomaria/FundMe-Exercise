// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// --- TASK ---
// Get funds from users
// Withraw the funds
// Set a Minimum funding value in USD

contract FundMe {

    function fund() public payable {
        // allow users to send $
        // set a minimum amount a user can send
        // 1. How do we send ETH to this contract?
        //  We make the function payable so that is can send ETH
        require(msg.value > 1e18, "didn't send enough ETH"); // 1e18 = 1ETH
    }

    function withdraw() public {}

}
