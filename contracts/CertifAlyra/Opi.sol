// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Opi is ERC20 {
    constructor() ERC20("OpiChain", "OPI") {
        _mint(msg.sender, 1000 * 10**18);
    }
}
