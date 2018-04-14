pragma solidity ^0.4.14;

import "./TokenAccessControl.sol";

/// @title Content extension of Token
contract TokenTags is TokenAccessControl {
    mapping (string => uint256[]) tokenIdsByTag;

    function TokenTags() public {
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

    function addTag(uint256 _tokenId, string _tag) external onlyCCO {
        tokenIdsByTag[_tag].push(_tokenId);
    }

    function removeTag(uint256 _tokenId, string _tag) external onlyCCO {
        uint length = tokenIdsByTag[_tag].length;
        uint i;
        uint indexToDelete = 0;
        bool tokenFound = false;
        for (i = 0; i < length - 1; i++) {
            if (tokenIdsByTag[_tag][i] == _tokenId) {
                indexToDelete = i;
                tokenFound = true;
            }
        }

        if (tokenFound) {
            delete tokenIdsByTag[_tag][indexToDelete];
        }
    }

    function getTokensByTag(string _tag) public view returns (uint256[] result) {
        result = tokenIdsByTag[_tag];
    }
}