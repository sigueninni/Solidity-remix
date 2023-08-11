// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MarrakechNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _idNFT;

    struct MarrakechNFTAttr {
        string what;
        string where;
    }

    MarrakechNFTAttr[] MarrakechNFTAttrs;

    constructor() ERC721("Marrakech", "KECH") {}

    function mintMarrakechNFT(
        address _to,
        string calldata _nftURI,
        string calldata _what,
        string calldata _where
    ) external returns (uint256) {
        uint256 newId;
        _idNFT.increment(); //To start at 1 as our NFTs starts at index 1
        newId = _idNFT.current();
        _mint(_to, newId);
        _setTokenURI(newId, _nftURI);
        
        MarrakechNFTAttrs.push(MarrakechNFTAttr(_what, _where));

        return newId;
    }
}
