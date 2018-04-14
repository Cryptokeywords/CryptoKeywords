pragma solidity ^0.4.14;

import "./TokenAccessControl.sol";
import "./TokenCore.sol";
import "./SaleClockOffer.sol";

/// @title Identity extension of Token
contract TokenIdentity is TokenAccessControl {
    mapping (address => string) ownerNickname;
    mapping (string => address) nicknameOwner;
    mapping (string => string) nicknames;
    mapping (address => string) profiles;
    mapping (address => string) links;

    TokenCore public core;
    SaleClockOffer public saleOffer;
    
    function TokenIdentity(address _coreAddress, address _saleOfferAddress) public {
        core = TokenCore(_coreAddress);
        saleOffer = SaleClockOffer(_saleOfferAddress);

        // the creator of the contract is the initial CEO
        ceoAddress = msg.sender;

        // the creator of the contract is also the initial COO
        cooAddress = msg.sender;
    }

    /// @notice No tipping!
    /// @dev Reject all Ether from being sent here.
    /// (Hopefully, we can prevent user accidents.)
    function() external payable {
        require(false);
    }

    /// @dev Access modifier for CFO-only functionality
    modifier onlyCCO() {
        require(core.isCCOAddress(msg.sender));
        _;
    }

    function nicknameAvailable(string nickname) 
        public 
        view 
        returns (bool) {
        string memory nicknameFound = nicknames[nickname];
        bytes memory nicknameFoundTest = bytes(nicknameFound);
        if (nicknameFoundTest.length > 0) {
            return false;
        } else {
            return true;
        }
    }

    function _getNicknameOwner(string nickname) 
        internal 
        view 
        returns (address) 
    {
        return nicknameOwner[nickname];
    }

    function updateNickname(string nickname) external {
        require(nicknameAvailable(nickname));

        string memory oldNickname;        
        oldNickname = ownerNickname[msg.sender];
        bytes memory oldNicknameTest = bytes(oldNickname);
        if (oldNicknameTest.length > 0) {
            delete nicknames[oldNickname];
            delete nicknameOwner[oldNickname];
        }

        ownerNickname[msg.sender] = nickname;
        nicknames[nickname] = nickname;
        nicknameOwner[nickname] = msg.sender;
    }

    function getNickname(address user) 
        external 
        view 
        returns (string) 
    {
        return ownerNickname[user];
    }

    function updateProfile(string _profile) external {
        profiles[msg.sender] = _profile;
    }

    function getProfile(address user) 
        external 
        view 
        returns (string) 
    {
        return profiles[user];
    }

    function updateLink(string _link) external {
        links[msg.sender] = _link;
    }

    function getLink(address user) 
        external 
        view 
        returns (string) 
    {
        return links[user];
    }
}