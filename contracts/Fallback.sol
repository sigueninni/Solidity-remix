// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

contract FallBack{

mapping (address=>uint) balances ;
event goodDeposit(address _addre, uint _value);
event badDeposit(address _addre);

fallback() payable external{

} 

receive() payable external{

} 

function depot() payable public{

}

}
