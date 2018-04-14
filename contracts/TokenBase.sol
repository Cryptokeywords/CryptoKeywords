pragma solidity ^0.4.14;

import "./TokenCommon.sol";
import "./TokenExtensions.sol";
import "./strings.sol";

/// @title Base contract for CryptoTokens. Holds all common structs, events and base variables.
/// @dev See the TokenCore contract documentation to understand how the various contract facets are arranged.
contract TokenBase is TokenExtensions {
    using strings for *;
    FriendContract friendContract;

    function TokenBase(address _friendContract) public {
        friendContract = FriendContract(_friendContract);
    }

    /*** EVENTS ***/

    /// @dev The Mint event is fired whenever a new token comes into existence. This obviously
    ///  includes any time a token is created through the giveMint method, but it is also called
    ///  when a new gen0 token is created.
    event Mint(address owner, uint256 tokenId, string uniqueText);

    /// @dev Transfer event as defined in current draft of ERC721. Emitted every time a token
    ///  ownership is assigned, including mints.
    event TransferV0(address from, address to, uint256 tokenId);

    /*** DATA TYPES ***/

    /*** CONSTANTS ***/

    // An approximation of currently how many seconds are in between blocks.
    uint256 public secondsPerBlock = 15;

    /*** STORAGE ***/

    /// @dev An array containing the Token struct for all Tokens in existence. The ID
    ///  of each token is actually an index into this array. Note that ID 0 is a negatoken,
    ///  the unToken, the mythical beast that is the parent of all gen0 tokens. A bizarre
    ///  creature that is both matron and sire... to itself! Has an invalid genetic code.
    ///  In other words, token ID 0 is invalid... ;-)
    TokenCommon.Token[] tokens;

    // Represents an offer on an NFT
    struct RelatedTokens {
        uint256 token1;
        uint256 token2;
        uint256 token3;
        uint256 token4;
    }

    mapping (uint256 => RelatedTokens) relatedTokens;

    /// @dev A mapping from token IDs to the address that owns them. All tokens have
    ///  some valid owner address, even gen0 tokens are created with a non-zero owner.
    mapping (uint256 => address) public tokenIndexToOwnerV0;
    mapping (uint256 => address) public tokenIndexToOwner; // copy from TokenERC721

    // @dev A mapping from owner address to count of tokens that address owns.
    //  Used internally inside balanceOf() to resolve ownership count.
    mapping (address => uint256) ownershipTokenCountV0;

    /// @dev A mapping from TokenIDs to an address that has been approved to call
    ///  transferFrom(). Each Token can only have one approved address for transfer
    ///  at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public tokenIndexToApprovedV0;

    /// @dev Assigns ownership of a specific Token to an address.
    function _transferV0(address _from, address _to, uint256 _tokenId) internal {
        // Since the number of tokens is capped to 2^32 we can't overflow this
        ownershipTokenCountV0[_to]++;
        // transfer ownership
        tokenIndexToOwnerV0[_tokenId] = _to;
        // When creating new tokens _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            ownershipTokenCountV0[_from]--;
            // clear any previously approved ownership exchange
            delete tokenIndexToApprovedV0[_tokenId];
        }
        // Emit the transfer event.
        TransferV0(_from, _to, _tokenId);
    }

    /// @dev An internal method that creates a new token and stores it. This
    ///  method doesn't do any checking and should only be called when the
    ///  input data is known to be valid. Will generate both a Mint event
    ///  and a Transfer event.
    /// @param _uniqueText The unique text.
    /// @param _owner The inital owner of this token, must be non-zero (except for the unToken, ID 0)
    function createToken(
        string _uniqueText,
        address _owner
    )
        external
        returns (uint256)
    {
        require(friendContract.isFriend(msg.sender));

        // Require that it's never been created before.
        require(index.uniqueTextAvailable(_uniqueText));

        TokenCommon.Token memory _tokenItem = TokenCommon.Token({
            uniqueText: _uniqueText,
            firstOwner: _owner,
            mintTime: uint64(now),
            isHidden: false
        });
        uint256 newTokenId = tokens.push(_tokenItem) - 1;
        index.setUniqueTextToTokenIndex(_uniqueText, newTokenId);

        // It's probably never going to happen, 4 billion tokens is A LOT, but
        // let's just be 100% sure we never let this happen.
        require(newTokenId == uint256(uint32(newTokenId)));

        // emit the mint event
        Mint(
            _owner,
            newTokenId,
            _tokenItem.uniqueText
        );

        _setRelatedTokens(newTokenId, _uniqueText);

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _transferV0(0, _owner, newTokenId);

        return newTokenId;
    }

    function _setRelatedTokens(uint256 _tokenId, string _uniqueText) internal {
        var texts = _uniqueText.toSlice();
        var delim = " ".toSlice();
        var parts = new string[](texts.count(delim) + 1);
        for(uint i = 0; i < parts.length; i++) {
            parts[i] = texts.split(delim).toString();
        }

        //var words = new string[](texts.count(delim) + 1);
        uint256 _relatedToken1;
        uint256 _relatedToken2;
        uint256 _relatedToken3;
        uint256 _relatedToken4;
        if (parts.length > 1) {
            _relatedToken1 = index.getTokenId(parts[0]);
            require(_relatedToken1 > 0);
        }
        if (parts.length >= 2) {
            _relatedToken2 = index.getTokenId(parts[1]);
            require(_relatedToken2 > 0);
        }
        if (parts.length >= 3) {
            _relatedToken3 = index.getTokenId(parts[3]);
            require(_relatedToken3 > 0);
        }
        if (parts.length >= 4) {
            _relatedToken4 = index.getTokenId(parts[4]);
            require(_relatedToken4 > 0);
        }

        relatedTokens[_tokenId] = RelatedTokens({
            token1: _relatedToken1,
            token2: _relatedToken2,
            token3: _relatedToken3,
            token4: _relatedToken4
        });
    }

    function setHidden(uint256 _tokenId, bool _isHidden) external onlyCLevel {
        tokens[_tokenId].isHidden = _isHidden;
    }

    function isHidden(uint256 _tokenId) external view returns (bool) {
        return tokens[_tokenId].isHidden;
    }

    // Any C-level can fix how many seconds per blocks are currently observed.
    function setSecondsPerBlock(uint256 secs) external onlyCLevel {
        // require(secs < cooldowns[0]);
        secondsPerBlock = secs;
    }

    function setOwner(uint256 _tokenId, address owner) external {
        require(friendContract.isFriend(msg.sender));

        tokenIndexToOwner[_tokenId] = owner;
    }
}
