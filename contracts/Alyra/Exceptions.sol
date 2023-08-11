// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.12;

contract Alice {
   function ping(uint) public pure  returns (uint){
       revert("test");
   }
}
contract Bob   {
   uint public x = 0;
   function pong(Alice c) public{
       x = 1;
       c.ping(42);
       //address(c).call("ping");
       x = 2;
   }
} 