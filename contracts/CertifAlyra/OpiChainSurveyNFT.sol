// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/// @title  OpiChain Survey NFT
/// @author Saad Igueninni
/// @notice ERC721 NFT associated to on survey
/// @dev Inherits the OpenZepplin Ownable ,ERC721URIStorage,Counters & Strings contracts
contract OpiChainSurveyNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    enum SurveyStatus {
        OnGoing,
        Terminated
    }

    struct Question {
        uint256 idQuestion;
        string textQuestion;
    }

    struct Answer {
        uint256 idAnswer;
        uint256 idQuestion;
        string textAnswer;
    }

    struct Survey {
        uint256 id;
        string description;
        SurveyStatus surveyStatus;
        Question[] questions;
    }

    //Keep the record of  ownership of surveys
    //mapping(uint256 => string) public tokenURIExists;
    //Keep the record for nfts value => give id returns cost
    // mapping(uint256 => uint256) public tokenIdToValue;

    mapping(address => Survey[]) surveys;
    address marketplaceContract;

    Counters.Counter private _idQuestion;
    Counters.Counter private _idAnswer;
    Counters.Counter private _idSurveyNFT;

    event surveyCreated(address _ownerSurvey, uint256 _id);
    event surveyDeleted(address _ownerSurvey, uint256 _id);
    event surveyNFTMinted(address _ownerSurvey, uint256 _id);

    //  event revokedOpiID(address _profileAddress);
    //  event updatedOpiID(address _profileAddress);

    constructor(address _marketplaceContract) ERC721("OpiChainSurvey", "OPS") {
        marketplaceContract = _marketplaceContract;
    }

    // ::::::::::::: MODIFIERS ::::::::::::: //

    // ::::::::::::: GETTERS ::::::::::::: //

    // ::::::::::::: SURVEYS HANDLING ::::::::::::: //

    function createSurvey(address _ownerSurvey, string memory _description)
        external
    {
        //surveys[_ownerSurvey].push(Survey(_userId, _roleId));
    }

    //Mint only when in status Terminated
    function mintSurvey() external {
        setApprovalForAll(marketplaceContract, true);
    }

    function deleteSurvey(address) external {}

    // ::::::::::::: NFT SURVEY MANAGEMENT ::::::::::::: //

    // ::::::::::::: OVVERIDES ::::::::::::: //
}
