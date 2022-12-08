// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OpiSurveysMarketPlace is ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _nftsSold;
    Counters.Counter private _nftCount;

    IERC20 public opiToken;
    IERC721 public surveyOpiNFT;

    uint256 public LISTING_FEE = 0.0001 ether;

    mapping(uint256 => SurveyNFT) private _idToNFT;

    struct SurveyNFT {
        uint256 id;
        address payable seller;
        address payable owner;
        uint256 price;
        bool listed;
    }
    event SurveyNFTListed(
        uint256 id,
        address seller,
        address owner,
        uint256 price
    );
    event SurveyNFTSold(
        uint256 id,
        address seller,
        address owner,
        uint256 price
    );

    constructor(IERC20 _opiTokenAdrress,IERC721 _surveyOpiNFT) {
        opiToken = _opiTokenAdrress;
        surveyOpiNFT = _surveyOpiNFT;
    }

    // List the NFT on the marketplace
    function listNft(
        address _nftContract,
        uint256 _tokenId,
        uint256 _price
    ) public payable nonReentrant {
        require(_price > 0, "Price must be at least 1 wei");
        require(msg.value == LISTING_FEE, "Not enough ether for listing fee");

       //IERC721(_nftContract).transferFrom(msg.sender, address(this), _tokenId);
        surveyOpiNFT.transferFrom(msg.sender, address(this), _tokenId);

        _nftCount.increment();

        _idToNFT[_tokenId] = SurveyNFT(
            _tokenId,
            payable(msg.sender),
            payable(address(this)),
            _price,
            true
        );

        emit SurveyNFTListed(
            _tokenId,
            msg.sender,
            address(this),
            _price
        );
    }

    // Buy an NFT
    function buyNft(address _nftContract, uint256 _tokenId)
        public
        payable
        nonReentrant
    {
        SurveyNFT storage nft = _idToNFT[_tokenId];
        require(
            msg.value >= nft.price,
            "Not enough ether to cover asking price"
        );

        address payable buyer = payable(msg.sender);
        payable(nft.seller).transfer(msg.value);
        surveyOpiNFT.transferFrom(address(this), buyer, nft.id);
        payable(owner()).transfer(LISTING_FEE);
        nft.owner = buyer;
        nft.listed = false;

        _nftsSold.increment();
        emit SurveyNFTSold(
            nft.id,
            nft.seller,
            buyer,
            msg.value
        );
    }

    // Resell an NFT purchased from the marketplace
    function resellNft(
        address _nftContract,
        uint256 _tokenId,
        uint256 _price
    ) public payable nonReentrant {
        require(_price > 0, "Price must be at least 1 wei");
        require(msg.value == LISTING_FEE, "Not enough ether for listing fee");

        surveyOpiNFT.transferFrom(msg.sender, address(this), _tokenId);

        SurveyNFT storage nft = _idToNFT[_tokenId];
        nft.seller = payable(msg.sender);
        nft.owner = payable(address(this));
        nft.listed = true;
        nft.price = _price;

        _nftsSold.decrement();
        emit SurveyNFTListed(
            _tokenId,
            msg.sender,
            address(this),
            _price
        );
    }

    function getListingFee() public view returns (uint256) {
        return LISTING_FEE;
    }

    function getListedNfts() public view returns (SurveyNFT[] memory) {
        uint256 nftCount = _nftCount.current();
        uint256 unsoldNftsCount = nftCount - _nftsSold.current();

        SurveyNFT[] memory nfts = new SurveyNFT[](unsoldNftsCount);
        uint256 nftsIndex = 0;
        for (uint256 i = 0; i < nftCount; i++) {
            if (_idToNFT[i + 1].listed) {
                nfts[nftsIndex] = _idToNFT[i + 1];
                nftsIndex++;
            }
        }
        return nfts;
    }

    function getMyNfts() public view returns (SurveyNFT[] memory) {
        uint256 nftCount = _nftCount.current();
        uint256 myNftCount = 0;
        for (uint256 i = 0; i < nftCount; i++) {
            if (_idToNFT[i + 1].owner == msg.sender) {
                myNftCount++;
            }
        }

        SurveyNFT[] memory nfts = new SurveyNFT[](myNftCount);
        uint256 nftsIndex = 0;
        for (uint256 i = 0; i < nftCount; i++) {
            if (_idToNFT[i + 1].owner == msg.sender) {
                nfts[nftsIndex] = _idToNFT[i + 1];
                nftsIndex++;
            }
        }
        return nfts;
    }

    function getMyListedNfts() public view returns (SurveyNFT[] memory) {
        uint256 nftCount = _nftCount.current();
        uint256 myListedNftCount = 0;
        for (uint256 i = 0; i < nftCount; i++) {
            if (
                _idToNFT[i + 1].seller == msg.sender && _idToNFT[i + 1].listed
            ) {
                myListedNftCount++;
            }
        }

        SurveyNFT[] memory nfts = new SurveyNFT[](myListedNftCount);
        uint256 nftsIndex = 0;
        for (uint256 i = 0; i < nftCount; i++) {
            if (
                _idToNFT[i + 1].seller == msg.sender && _idToNFT[i + 1].listed
            ) {
                nfts[nftsIndex] = _idToNFT[i + 1];
                nftsIndex++;
            }
        }
        return nfts;
    }
}
