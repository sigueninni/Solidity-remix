// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/// @title  OpiChain SBT contract
/// @author Saad Igueninni
/// @notice ERC721 not transferable, bound to Soul
/// @dev Inherits the OpenZepplin Ownable ,ERC721URIStorage,Counters & Strings contracts
contract OpiChainSBT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    enum Gender {
        Male,
        Female
    }

    enum Role {
        Sounder,
        Surveyed
    }

    struct OpiProfile {
        uint256 OpiIdCounter;
        string name;
        Gender gender;
        uint256 age;
        Role role;
        bool isOpiIdGranted;
    }

    //mapping(address=>bool) grantedOPIIds;
    mapping(address => OpiProfile) OpiProfiles;
    Counters.Counter private _OpiIdCounter;

    event grantedOpiID(OpiProfile _newOpiProfile);
    event revokedOpiID(address _profileAddress);
    event updatedOpiID(address _profileAddress);

    constructor() ERC721("OpiChainID", "OpiId") {}

    /*        address test = 0xd9cB466B10b86Da36Cb7E39d6DD86d25A500Ccd6;
        grantOpiID( test,
       // "https://gateway.pinata.cloud/ipfs/QmQzEEbvYSV2atiDv8PdT4WuNyjTLbKpEWFVqFFVFLGAut/1.json",
        "saad",
        38,
        0,
        0); */

    // ::::::::::::: MODIFIERS ::::::::::::: //
    modifier onlySounders(address _profileAddress) {
        require(
            (OpiProfiles[_profileAddress].isOpiIdGranted &&
                OpiProfiles[_profileAddress].role == Role.Sounder),
            "You are not a sounder"
        );
        _;
    }

    modifier onlySurveyeds(address _profileAddress) {
        require(
            (OpiProfiles[_profileAddress].isOpiIdGranted &&
                OpiProfiles[msg.sender].role == Role.Surveyed),
            "You are not a surveyed"
        );
        _;
    }

    modifier opiIdExists(address _profileAddress) {
        require(
            OpiProfiles[_profileAddress].isOpiIdGranted,
            "OpiID do not exists"
        );
        _;
    }

    // ::::::::::::: GETTERS ::::::::::::: //
    function getOpiID(address _profileAddress)
        external
        view
        onlyOwner
        opiIdExists(_profileAddress)
        returns (OpiProfile memory)
    {
        return OpiProfiles[_profileAddress];
    }

    function isGrantedOpiID(address _profileAddress)
        external
        view
        onlyOwner
        returns (bool)
    {
        return OpiProfiles[_profileAddress].isOpiIdGranted;
    }

    function isSounder(address _profileAddress)
        external
        view
        onlyOwner
        returns (bool)
    {
        return (OpiProfiles[_profileAddress].isOpiIdGranted &&
            OpiProfiles[_profileAddress].role == Role.Sounder);
    }

    function isSurveyed(address _profileAddress)
        external
        view
        onlyOwner
        returns (bool)
    {
        return (OpiProfiles[_profileAddress].isOpiIdGranted &&
            OpiProfiles[_profileAddress].role == Role.Surveyed);
    }

    // ::::::::::::: MEMBERS MANAGEMENT ::::::::::::: //
    function grantOpiID(
        address _profileAddress,
        // string memory _SBTUri,
        string memory _name,
        uint256 _age,
        uint8 _gender,
        uint8 _role
    ) public onlyOwner returns (uint256) {
        //To change to external after test
        require(
            !OpiProfiles[_profileAddress].isOpiIdGranted,
            "OpiID already exists"
        );

        _OpiIdCounter.increment(); //To start at 1
        uint256 newOpiID = _OpiIdCounter.current();
        OpiProfile memory newOpiProfile;

        //Add new Profile
        newOpiProfile.OpiIdCounter = newOpiID;
        newOpiProfile.name = _name;
        newOpiProfile.age = _age;
        newOpiProfile.gender = Gender(_gender);
        newOpiProfile.role = Role(_role);
        newOpiProfile.isOpiIdGranted = true;
        OpiProfiles[_profileAddress] = newOpiProfile;

        _mint(_profileAddress, newOpiID);

        string memory urinumber = Strings.toString(newOpiID);
        string
            memory tokenURI = "https://ipfs.io/ipfs/QmQiceiGFxV72zuKhy3ggZhoFu1Gcuvu35khedjtxAML6G/";
        string memory _SBTUri = string.concat(tokenURI, urinumber, ".json");

        _setTokenURI(newOpiID, _SBTUri);

        emit grantedOpiID(newOpiProfile);
        return newOpiProfile.OpiIdCounter;
    }

    function revokeOpiID(address _profileAddress) external onlyOwner {
        require(
           OpiProfiles[_profileAddress].isOpiIdGranted,
            "OpiID do not exists"
        );
        emit revokedOpiID(_profileAddress);
        delete OpiProfiles[_profileAddress];
    }

    function updateOpiID(
        address _profileAddress,
        string calldata _name,
        uint256 _age,
        uint8 _gender,
        uint8 _role
    ) external onlyOwner {
        require(
           OpiProfiles[_profileAddress].isOpiIdGranted,
            "OpiID do not exists"
        );

        OpiProfile memory UpdOpiProfile;

        UpdOpiProfile = OpiProfiles[_profileAddress];
        UpdOpiProfile.name = _name;
        UpdOpiProfile.age = _age;
        UpdOpiProfile.gender = Gender(_gender);
        UpdOpiProfile.role = Role(_role);
        OpiProfiles[_profileAddress] = UpdOpiProfile;

        emit updatedOpiID(_profileAddress);
    }

    // ::::::::::::: OVVERIDES ::::::::::::: //
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal virtual override {
        require(
            from == address(0),
            "SBT : not possible de Transfer your OpiId"
        );
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }
}
