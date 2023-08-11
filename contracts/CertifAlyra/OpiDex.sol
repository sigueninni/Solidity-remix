// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OpiDex is Ownable {
    IERC20 opi;
    address public opiContractAddress;

    //OPI price in ETH
    uint256 public tokensPerEth = 50;

    event OpiBuyed(
        address _sounderAddress,
        uint256 _amountOfETH,
        uint256 _amountOfOPIs
    );

    constructor(address _opiAddress) {
        opi = IERC20(_opiAddress);
        opiContractAddress = _opiAddress;
       // opi.initSupply(address(this),1000);
    }

    /**
     * @notice Sounders users to buy token for ETH
     */
    function buyTokens() public payable returns (uint256 tokenAmount) {
        require(msg.value > 0, "ETH needed to buy OPIs");

        uint256 amountToBuy = msg.value * tokensPerEth;

        // check if the Vendor Contract has enough amount of tokens for the transaction
        uint256 OpiDexBalance = opi.balanceOf(opiContractAddress);
        require(
            OpiDexBalance >= amountToBuy,
            "Not enough OPIs in balance of OpiDex"
        );

        // Transfer token to the msg.sender
        bool sent = opi.transfer(msg.sender, amountToBuy);
        /*  opi.approve(msg.sender,amountToBuy);
        bool sent = opi.transferFrom(
            opiContractAddress,
            msg.sender,
            amountToBuy
        );*/
        require(sent, "Failed to transfer OPIs to user");

        // emit the event
        emit OpiBuyed(msg.sender, msg.value, amountToBuy);

        return amountToBuy;
    }

    /**
     * @notice Allow the owner of the contract to withdraw ETH
     */
    function withdraw() public onlyOwner {
        uint256 OpiDexBalance = address(this).balance;
        require(OpiDexBalance > 0, "OpiDexBalance has nothing to withdraw");

        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to withdraw!");
    }
}
