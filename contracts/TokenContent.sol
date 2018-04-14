pragma solidity ^0.4.14;

import "./TokenAccessControl.sol";
import "./TokenERC721.sol";

/// @title Content extension of Token
contract TokenContent is TokenAccessControl {
    mapping (uint256 => mapping(address => string)) internal tokenOwnerMetadata;
    TokenERC721 erc721;

    function TokenContent(
        address _tokenERC721) {
        erc721 = TokenERC721(_tokenERC721);

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

    function setMetadata(
        uint256 _tokenId, 
        string _metadata) external 
    {
        address owner = erc721.ownerOf(_tokenId);
        require(msg.sender == owner);

        tokenOwnerMetadata[_tokenId][msg.sender] = _metadata;
    }

    /// @param _id The ID of the token of interest.
    function getMetadata(uint256 _id, address seller)
        external
        view
        returns (string) 
    {
        return tokenOwnerMetadata[_id][seller];
    }
}