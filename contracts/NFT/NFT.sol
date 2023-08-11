// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract NFT {
    enum Rarity {
        NOTRARE,
        RARE,
        LEGENDARY
    }

    struct SNFT{
        uint id;
        string nameCollection;
        Rarity rarity;
    }

    mapping(address=>SNFT) public nfties;

    function addNFT(address _addr) external {
        nfties[_addr] = SNFT(1,"test",Rarity.RARE);

    }
}
