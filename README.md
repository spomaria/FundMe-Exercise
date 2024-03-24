# Creating a Crowd Sourcing Contract

## Introduction
This project stems from Smart Contract development learning at [cyfrinupdraft](https://updraft.cyfrin.io).

The aim of the project is to create a Smart Contract for Crowd Funding where the funds can be withdrawn by the owner and spent.

## Smart Contract Development
### 1. The Library
We shall create a library for other functions in our Smart Contract that are re-usable and do not send or receive ether. These functions can be inherited by other Smart Contracts as methods when imported. All functions in library should be marked as internal and should not contain any state variables. Our library has the following features:

1. Interface: the Smart Contract inherited an interface from Chainlink via named import which allows it to read the value of the native coin of the blockchain with the help of the below code. Importing the interface enables our Smart Contract to interact with it since it will have the Application Binary Interface (ABI) of the interface.
    ```
    // SPDX-License-Identifier: MIT
    pragma solidity ^0.8.18;

    import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

    library PriceConverter {}

    ```

2. The getPrice function: enables the user to obtain the price of ETH from Chainlink in USD and return it to the caller as a 'uint256' variable
    ```
    // Create a function that gets the price of the token
    function getPrice() internal view returns (uint256) {
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
    ```

3. The getConversionRate function enables the Smart Contract to convert the ETH amount intended to be sent by the user to USD (using the current market price) and compare it to the minimum threshold amount in USD set by the creator of the contract.
    ```
    // Create a function the converts the 'msg.value' base on the price
    function getConversionRate(uint ethAmount) internal view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethAmount * ethPrice)/ 1e18;
        return ethAmountInUsd;

    }
    ``` 

### 2. The Smart Contract
The Smart contract has the following components

1. Imported Library: the Smart Contract imported the `PriceConverter` library thereby allowing varibles of type `uint256` access to its methods. This is made possible by the following lines of code:
    ```
    // This named import enables us use the functionalities of the 
    // PriceConverter library
    import { PriceConverter } from "./PriceConverter.sol";

    contract FundMe {

        // This command will enable all variables of type uint256 to access the 
        // methods in the PriceConverter library
        using PriceConverter for uint256;

        // -- other lines of code should follow here
    }

    ```

2. The fund function: this allows a user to send fund to the Smart Contract    and includes the user address in the list of funders. The `msg.value` has access to the methods of the `PriceConverter` library because it is of type `uint256`.
    ```
    function fund() public payable {
        // allow users to send $
        // set a minimum amount a user can send
        // 1. How do we send ETH to this contract?
        //  We make the function payable so that is can send ETH
        require(msg.value.getConversionRate() > minimumUsd, "didn't send enough ETH"); // 1e18 = 1ETH
        // Include this address in the list of funders
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    ```

3. The withdraw function allows only the owner of the Contract to withdraw the funds. The function uses a modifier `onlyOwner` in the function declaration to ensure that only the owner of the Contract can call this function. The function also resets the array of funders to a zero array and resets the contributions of all addresses to zero.
    ```
    function withdraw() public onlyOwner {
        // Reset all contributions to zero using a for loop
        for(uint256 indexFunder; indexFunder < funders.length;){
            address funder = funders[indexFunder];
            addressToAmountFunded[funder] = 0;
            // We use unchecked for gas optimization since we know
            // that our variable cannot overflow
            unchecked{
                indexFunder ++;
            }
        }

        // Reset the funders array
        funders = new address[](0);

        // There are three ways to withdraw the funds to the caller of the function
        // 1. transfer
        // We make the msg.sender address payable so as to recieve ether
        // Note that the transfer function reverts automatically when an error is encountered
        // payable(msg.sender).transfer(address(this).balance);

        // 2. send
        // Note that the send function does not revert automatically when an error is encountered
        // So, we use a require keyword to ensure it reverts in the event of any error
        // bool success = payable(msg.sender).send(address(this).balance);
        // require(success, "Send Failed");

        // 3. call
        // Note that the call function returns two variables, a bool and bytes.
        // However, we are only interested in the bool variable
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");
    }

    ```
4. The receive function enables a user to still send ether to the Contract without calling the `fund` function. The receive function however, routes such users to the `fund` function so that such addresses are added to the array of `funders` accordingly.
    ```
    // add the receive function to enable the contract take note of those who try 
    // to send ether without using the fund function
    receive() external payable { 
        // This function will route any user who tries to send some ether to the fund function
        // Thereby, adding such user to the list of funders
        fund();
    }
    ```

5. The fallback function enables the Contract to revert the transaction of users who attempt to send less than the minimum allowed amount without calling the `fund`. The Smart Contract is able to revert such transactions by routing such calls to the `fund` function.
    ```
    fallback() external payable { 
        // This function will route any user who tries to send some ether to the fund function
        // In this way, any user that tries to send less than the minimum amount allowed 
        // and did not call the fund function will equally have their transaction reverted
        fund();
    }
    ```

## Authors
Nengak Emmanuel Goltong 

[@NengakGoltong](https://twitter.com/nengakgoltong) 
[@nengakgoltong](https://www.linkedin.com/in/nengak-goltong-81009b200)

Under the tutelage of 

Patrick Collins
[@PatrickAlphaC](https://twitter.com/PatrickAlphaC)

## License
This project is licensed under the MIT License - see the LICENSE.md file for details