// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

//Interface OpiChainSBT
/*interface OpiChainSBT {
    function isSounder(address _profileAddress) external view returns (bool);
    function isSurveyed(address _profileAddress) external view returns (bool);
}*/

/// @title  OpiChain Survey NFT
/// @author Saad Igueninni
/// @notice ERC721 NFT associated to on survey
/// @dev Inherits the OpenZepplin Ownable ,ERC721URIStorage,Counters & Strings contracts
contract OpiChainSurveyNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _idQuestion;
    Counters.Counter private _idAnswer;
    Counters.Counter private _idSurveyNFT;

    enum SurveyStatus {
        OnGoing,
        Terminated
    }

    struct Question {
        uint256 idQuestion;
        string textQuestion;
    }

    struct Answer {
        address ownerAnswer;
        uint256 idAnswer;
        string textAnswer;
    }

    struct Survey {
        uint256 idSurvey;
        address owner;
        string description;
        SurveyStatus surveyStatus;
        bool exists;
        bool minted;
    }

    mapping(uint256 => Survey) idToSurveys;
    //mapping(uint256 => address) idToOwner;
    mapping(address => Survey[]) addressToSurveys;
    // mapping( uint => Answer[])  questionToAnswers;
    mapping(uint256 => Question[]) surveyToQuestion;
    mapping(uint256 => mapping(uint256 => Answer[])) surveyToQuestionToAnswer;


    uint public constant SurveyUnitCost = 500;  
    address marketplaceContract;
   // OpiChainSBT sbtContract;
    IERC20 opi;

    event surveyCreated(address _ownerSurvey, uint256 _idSurvey);
    event surveyTerminated(uint256 _idSurvey);
    event surveyDeleted(uint256 _idSurvey);
    event surveyNFTMinted(uint256 _idSurvey);
    event questionAdded(uint256 _idQuestion, uint256 _idSurvey);
    event answerGiven(address _ownerAnswer, uint256 _idAnswer , uint256 _idSurvey, uint256 idQuestion);

    //constructor(address _marketplaceContract, address _opiChainSBTAddress,address _opiAddress)
    constructor()
        ERC721("OpiChainSurvey", "OPS")
    {
        //marketplaceContract = _marketplaceContract;
       // sbtContract = OpiChainSBT(_opiChainSBTAddress);
       // opi = IERC20(_opiAddress);
    }

    // ::::::::::::: MODIFIERS ::::::::::::: //
    modifier SurveyExist(uint256 _idSurvey) {
        require(idToSurveys[_idSurvey].exists, "Survey do not exists");
        _;
    }

    /* modifier onlySounders() {
        require(sbtContract.isSounder(msg.sender), "You are not a sounder");
        _;
    }

    modifier onlySurveyeds() {
        require(sbtContract.isSurveyed(msg.sender), "You are not a surveyed");
        _;
    }*/

    // ::::::::::::: GETTERS ::::::::::::: //
    function getSurveyStatusById(uint256 _idSurvey)
        public
        view
        returns (uint256)
    {
        return (uint256(idToSurveys[_idSurvey].surveyStatus));
    }

    function getSurveyByAddress(address _ownerSurvey, uint256 _idSurvey)
        public
        view
        returns (Survey memory)
    {
        return addressToSurveys[_ownerSurvey][_idSurvey];
    }

    // ::::::::::::: SETTERS ::::::::::::: //
    function setSurveyTerminated(uint256 _idSurvey)
        internal
        SurveyExist(_idSurvey)
    {
        idToSurveys[_idSurvey].surveyStatus = SurveyStatus.Terminated;
        //Check if we need the mapping
        emit surveyTerminated(_idSurvey);
    }

    // ::::::::::::: SURVEYS HANDLING ::::::::::::: //
    function createSurvey(address _ownerSurvey, string memory _description)
        external
        onlyOwner
    {
        //require assez de balance 
        uint256 newIdSurvey = _idSurveyNFT.current();
        Survey memory newSurvey;
        newSurvey = Survey(
            newIdSurvey,
            _ownerSurvey,
            _description,
            SurveyStatus.OnGoing,
            true,
            false
        );

        //Update mapping
        idToSurveys[newIdSurvey] = newSurvey;
        addressToSurveys[_ownerSurvey].push(newSurvey);
        _idSurveyNFT.increment();
        emit surveyCreated(_ownerSurvey, newIdSurvey);

    }

    //Mint only when in status Terminated
    function mintSurvey(uint256 _idSurvey) external onlyOwner {
        require(
            getSurveyStatusById(_idSurvey) == uint256(SurveyStatus.Terminated),
            "Survey not terminated"
        );

        address _ownerSurvey;

        setApprovalForAll(marketplaceContract, true); //Give approval to marketplace
        _ownerSurvey = idToSurveys[_idSurvey].owner;
        _mint(_ownerSurvey, _idSurvey);

        string memory urinumber = Strings.toString(_idSurvey);
        string
            memory tokenURI = "https://ipfs.io/ipfs/QmQzEEbvYSV2atiDv8PdT4WuNyjTLbKpEWFVqFFVFLGAut/"; //To change by CID of !!
        string memory _SBTUri = string.concat(tokenURI, urinumber, ".json");

        _setTokenURI(_idSurvey, _SBTUri);

        emit surveyNFTMinted(_idSurvey);
    }

  
    function terminateSurvey(uint256 _idSurvey) external 
    //onlySurveyeds
     {
        require(
            getSurveyStatusById(_idSurvey) == uint256(SurveyStatus.OnGoing),
            "Survey not onGoing!"
        );
        setSurveyTerminated(_idSurvey);
        emit surveyTerminated(_idSurvey);
    }

    function deleteSurvey(uint256 _idSurvey) external {
        delete idToSurveys[_idSurvey];
        emit surveyDeleted(_idSurvey);
    }

    // ::::::::::::: QUESTIONS MANAGEMENT ::::::::::::: //

  function addQuestion(uint256 _idSurvey , string memory _question) external 
  //onlySurveyeds
  {
       uint256 newIdQuestion = _idQuestion.current();
        surveyToQuestion[_idSurvey].push( Question(newIdQuestion,_question));
      _idQuestion.increment();
      emit questionAdded(newIdQuestion, _idSurvey);
  }



  // ::::::::::::: ANSWERS MANAGEMENT ::::::::::::: //
  function giveAnswer(uint256 _idSurvey , uint256 _idQuestionAnswer ,string memory _answer) external 
  //onlySounders
  {

      uint256 newIdAnswer= _idAnswer.current();
        surveyToQuestionToAnswer[_idSurvey][_idQuestionAnswer].push(Answer(msg.sender,newIdAnswer,_answer));
      _idAnswer.increment();
      emit answerGiven(msg.sender,newIdAnswer , _idSurvey, _idQuestionAnswer);
  }



    //reveal_results -> une fois TERMINATED , & vendu on peut reveal.

    // ::::::::::::: OVVERIDES ::::::::::::: //
}
