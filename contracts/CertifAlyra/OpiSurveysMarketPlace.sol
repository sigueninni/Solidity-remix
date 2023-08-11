// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OpiSurveysMarketPlace is ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _nftsSurveySold;
    Counters.Counter private _nftSurveyCount;

    IERC20 public opiToken;
    IERC721 public surveyOpiNFT;

    uint256 public LISTING_OPICHAIN_FEE = 0.0001 ether; // we keep ether as fees to have a stable fee

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
        address owner, //current owner of contract
        uint256 price
    );
    event SurveyNFTSold(
        uint256 id,
        address seller,
        address owner,
        uint256 price
    );

    constructor(IERC20 _opiTokenAdrress, IERC721 _surveyOpiNFT) {
        opiToken = _opiTokenAdrress;
        surveyOpiNFT = _surveyOpiNFT;
    }

    // ::::::::::::: MODIFIERS ::::::::::::: //

    // ::::::::::::: GETTERS ::::::::::::: //
    function getListingFee() public view returns (uint256) {
        return LISTING_OPICHAIN_FEE;
    }

    function getListedNfts() public view returns (SurveyNFT[] memory) {
        uint256 nftCount = _nftSurveyCount.current();
        uint256 unsoldNftsCount = nftCount - _nftsSurveySold.current();

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
        uint256 nftCount = _nftSurveyCount.current();
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
        uint256 nftCount = _nftSurveyCount.current();
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

    // ::::::::::::: MARKETPLACE MANAGEMENT ::::::::::::: //

    // List the NFT on the marketplace
    function listNft(uint256 _tokenId, uint256 _price)
        public
        payable
        nonReentrant
    {
        require(_price > 0, "Price must be at least 1 opi");
        require(
            msg.value == LISTING_OPICHAIN_FEE,
            "Not enough ether for listing fee"
        );
        //require tokenid est au statut Terminated!

        //IERC721(_nftContract).transferFrom(msg.sender, address(this), _tokenId);
        surveyOpiNFT.transferFrom(msg.sender, address(this), _tokenId);

        _nftSurveyCount.increment();

        _idToNFT[_tokenId] = SurveyNFT(
            _tokenId,
            payable(msg.sender),
            payable(address(this)),
            _price,
            true
        );

        emit SurveyNFTListed(_tokenId, msg.sender, address(this), _price);
    }

    // Buy a Survey result
    function buySurveyResultNft(address _nftContract, uint256 _tokenId)
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
        payable(owner()).transfer(LISTING_OPICHAIN_FEE);
        nft.owner = buyer;
        nft.listed = false;

        _nftsSurveySold.increment();
        emit SurveyNFTSold(nft.id, nft.seller, buyer, msg.value);
    }

    // Resell the Survey results
    function resellSurveyResultNft(
        address _nftContract,
        uint256 _tokenId,
        uint256 _price
    ) public payable nonReentrant {
        require(_price > 0, "Price must be at least 1 wei");
        require(
            msg.value == LISTING_OPICHAIN_FEE,
            "Not enough ether for listing fee"
        );

        surveyOpiNFT.transferFrom(msg.sender, address(this), _tokenId);

        SurveyNFT storage nft = _idToNFT[_tokenId];
        nft.seller = payable(msg.sender);
        nft.owner = payable(address(this));
        nft.listed = true;
        nft.price = _price;

        _nftsSurveySold.decrement();
        emit SurveyNFTListed(_tokenId, msg.sender, address(this), _price);
    }
}
