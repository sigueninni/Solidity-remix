// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ExoERC721 is ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    constructor() ERC721("OpiChain","OPI"){}

    function mintNFT(address to, string memory nftURI) external returns (uint){

        uint newItemId = _tokenIds.current();
        _mint(to,newItemId);
        _setTokenURI(newItemId, nftURI);

        _tokenIds.increment();
        return newItemId;

    }


}