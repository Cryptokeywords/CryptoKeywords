pragma solidity ^0.4.14;

import "./TokenAccessControl.sol";
import "./FriendContract.sol";

contract TokenIndex is TokenAccessControl {
    /// @dev A mapping from unique texts to token ID.
    ///  Used for search and retrieval.
    mapping (string => uint256) internal _uniqueTextToTokenIndex;

    mapping (uint256 => uint64) internal _tokenIndexToTrades;

    FriendContract friendContract;

    // Delegate constructor
    function TokenIndex(address _friendContract) public {
        friendContract = FriendContract(_friendContract);

        // the creator of the contract is the initial CEO
        ceoAddress = msg.sender;

        // the creator of the contract is also the initial COO
        cooAddress = msg.sender;
    }

    function getTrades(uint256 _tokenId) 
        public
        view
        returns (uint64)
    {
        return _tokenIndexToTrades[_tokenId];
    }

    function incrementTrades(uint256 _tokenId) external {
        require(friendContract.isFriend(msg.sender));
        uint64 trades = _tokenIndexToTrades[_tokenId] + 1;
        _tokenIndexToTrades[_tokenId] = trades;
    }

    function firstTradeCheck() external {
        require(friendContract.isFriend(msg.sender));
    }

    function uniqueTextAvailable(string _uniqueText) public view returns (bool) {
        return _uniqueTextToTokenIndex[_uniqueText] == 0;
    }

    function setUniqueTextToTokenIndex(string _uniqueText, uint256 _tokenId) public {
        require(friendContract.isFriend(msg.sender));
        _uniqueTextToTokenIndex[_uniqueText] = _tokenId;
    }

    function getTokenId(string uniqueText) public view returns (uint256) {
        return _uniqueTextToTokenIndex[uniqueText];
    }
}
