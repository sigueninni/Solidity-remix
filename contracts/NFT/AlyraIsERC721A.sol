// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Azuki is ERC721A, Ownable {
    //To concatenate the URL of an NFT
    using Strings for uint256;

    enum Step {
        Before,
        PublicSale,
        Gift
    }

    Step private sellingStep;

    uint256 private constant MAX_SUPPLY = 100;
    uint256 private constant MAX_GIFT = 5;
    uint256 private constant MAX_PUBLIC_SALE = MAX_SUPPLY - MAX_GIFT;

    uint256 private constant MAX_NFTS_PER_ADDRESS = 8;

    uint256 private constant PRICE = 0.0001 ether;

    mapping(address => uint256) numberNFTsMintedPerAddress;

    constructor() ERC721A("Alyra", "ALNFT") {}

    function publicSale(uint256 quantity) external payable  {
        require(sellingStep == Step.PublicSale, "Not the moment to mint");
        require(
            numberNFTsMintedPerAddress[msg.sender] + quantity <= MAX_NFTS_PER_ADDRESS,
            "You have minted too many NFTs"
        );
        require(msg.value >= quantity * PRICE, "Not enough funds provided");
        require(
            totalSupply() + quantity <= MAX_PUBLIC_SALE,
            "Supply limit exceeded"
        );
        numberNFTsMintedPerAddress[msg.sender] += quantity;
        _mint(msg.sender, quantity);
    }

    function gift(address _to, uint256 _quantity) external onlyOwner {
        require(sellingStep == Step.Gift, "Not the moment to give gifts");
        require(
            totalSupply() + _quantity <= MAX_PUBLIC_SALE,
            "Supply limit exceeded"
        );

        numberNFTsMintedPerAddress[_to] += _quantity;
        _mint(_to, _quantity);
    }

    function setStep(uint256 _step) external onlyOwner {
        sellingStep = Step(_step);
    }

    function getSellingStep() external view returns (Step) {
        return sellingStep;
    }

    function tokenURI(uint _tokenId) public view virtual override returns(string memory){
        require(_exists(_tokenId),"NFT not minted yet");
        return string(abi.encodePacked("ipfs://QmUqDEuxQ4gmp99ZqEfQRdnrh4YsnEAjhiDreUxwYCGuxo/",
        _tokenId.toString(),".json"));
        // ipfs://QmUqDEuxQ4gmp99ZqEfQRdnrh4YsnEAjhiDreUxwYCGuxo.json
    }
}
