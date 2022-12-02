// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

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

    modifier onlySounders() {
        require(
            (OpiProfiles[msg.sender].isOpiIdGranted &&
                OpiProfiles[msg.sender].role == Role.Sounder),
            "You are not a sounder"
        );
        _;
    }

    modifier onlySurveyeds() {
        require(
            (OpiProfiles[msg.sender].isOpiIdGranted &&
                OpiProfiles[msg.sender].role == Role.Surveyed),
            "You are not a surveyed"
        );
        _;
    }

    event grantedOpiID(address _profileAddress, uint256 _OpiIdCounter);
    event revokedOpiID(address _profileAddress);
    event updatedOpiID(address _profileAddress);

    constructor() ERC721("OpiChainID", "OpiId") {}

    function grantOpiID(
        address _profileAddress,
        string calldata _SBTUri,
        string calldata _name,
        uint256 _age,
        uint8 _gender,
        uint8 _role
    ) external onlyOwner returns (uint256) {
        require(
            OpiProfiles[msg.sender].OpiIdCounter == 0,
            "OpiID already exists"
        );
        uint256 newOpiID = _OpiIdCounter.current();
        OpiProfile memory newOpiProfile;
        _OpiIdCounter.increment(); //To start at 1

        //Add new Profile
        newOpiProfile.OpiIdCounter = newOpiID;
        newOpiProfile.name = _name;
        newOpiProfile.age = _age;
        newOpiProfile.gender = Gender(_gender);
        newOpiProfile.role = Role(_role);
        newOpiProfile.isOpiIdGranted = true;
        OpiProfiles[_profileAddress] = newOpiProfile;

        _mint(_profileAddress, newOpiID);
        _setTokenURI(newOpiID, _SBTUri);

        emit grantedOpiID(_profileAddress, newOpiProfile.OpiIdCounter);
        return newOpiID;
    }

    function revokeOpiID(address _profileAddress) external onlyOwner {
        require(
            OpiProfiles[msg.sender].OpiIdCounter != 0,
            "OpiID do not exists"
        );
        delete OpiProfiles[_profileAddress];
        emit revokedOpiID(_profileAddress);
    }

    function updateOpiID(
        address _profileAddress,
        string calldata _name,
        uint256 _age,
        uint8 _gender,
        uint8 _role
    ) external onlyOwner {
        require(
            OpiProfiles[msg.sender].OpiIdCounter != 0,
            "OpiID do not exists"
        );

        OpiProfile memory UpdOpiProfile;

        UpdOpiProfile = OpiProfiles[_profileAddress];
        UpdOpiProfile.name = _name;
        UpdOpiProfile.age = _age;
        UpdOpiProfile.gender = Gender(_gender);
        UpdOpiProfile.role = Role(_role);
        OpiProfiles[_profileAddress] = UpdOpiProfile;

        emit revokedOpiID(_profileAddress);
    }

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
