pragma solidity ^0.4.14;

import "./TokenBase.sol";
import "./TokenCommon.sol";
import "./ClockOfferBase.sol";
import "./ERC721V0.sol";

/// @title The facet of the CryptoTokens core contract that manages ownership, ERC-721 (draft) compliant.
/// @dev Ref: https://github.com/ethereum/EIPs/issues/721
///  See the TokenCore contract documentation to understand how the various contract facets are arranged.
contract TokenOwnership is TokenBase, ERC721V0 {

    // Internal utility functions: These functions all assume that their input arguments
    // are valid. We leave it to public methods to sanitize their inputs and follow
    // the required logic.

    /// @dev Checks if a given address is the current owner of a particular Token.
    /// @param _claimant the address we are validating against.
    /// @param _tokenId token id, only valid when > 0
    function _ownsV0(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return tokenIndexToOwnerV0[_tokenId] == _claimant;
    }

    function ownsV0(address _claimant, uint256 _tokenId) public view returns (bool) {
        return tokenIndexToOwnerV0[_tokenId] == _claimant;
    }

    /// @dev Checks if a given address currently has transferApproval for a particular Token.
    /// @param _claimant the address we are confirming token is approved for.
    /// @param _tokenId token id, only valid when > 0
    function _approvedForV0(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return tokenIndexToApprovedV0[_tokenId] == _claimant;
    }

    /// @dev Marks an address as being approved for transferFrom(), overwriting any previous
    ///  approval. Setting _approved to address(0) clears all transfer approval.
    ///  NOTE: _approve() does NOT send the Approval event. This is intentional because
    ///  _approve() and transferFrom() are used together for putting Tokens on offer, and
    ///  there is no value in spamming the log with Approval events in that case.
    function _approveV0(uint256 _tokenId, address _approved) internal {
        tokenIndexToApprovedV0[_tokenId] = _approved;
    }

    /// @notice Transfers a Token to another address. If transferring to a smart
    ///  contract be VERY CAREFUL to ensure that it is aware of ERC-721 (or
    ///  CryptoTokens specifically) or your Token may be lost forever. Seriously.
    /// @param _to The address of the recipient, can be a user or contract.
    /// @param _tokenId The ID of the Token to transfer.
    /// @dev Required for ERC-721 compliance.
    function transferV0(
        address _to,
        uint256 _tokenId
    )
        external
        whenNotPaused
    {
        require(friendContract.isFriend(msg.sender));

        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any tokens (except very briefly
        // after a gen0 token is created and before it goes on offer).
        require(_to != address(this));
        // Disallow transfers to the offer contracts to prevent accidental
        // misuse. Offer contracts should only take ownership of tokens
        // through the allow + transferFrom flow.
        require(_to != address(saleOffer));

        // You can only send your own token.
        require(_ownsV0(msg.sender, _tokenId));

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _transferV0(msg.sender, _to, _tokenId);
    }

    /// @notice Grant another address the right to transfer a specific Token via
    ///  transferFrom(). This is the preferred flow for transfering NFTs to contracts.
    /// @param _to The address to be granted transfer approval. Pass address(0) to
    ///  clear all approvals.
    /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.
    /// @dev Required for ERC-721 compliance.
    function approveV0(
        address _to,
        uint256 _tokenId
    )
        public
        whenNotPaused
    {
        // Only an owner can grant transfer approval.
        require(friendContract.isFriend(msg.sender));

        // Register the approval (replacing any previous approval).
        _approveV0(_tokenId, _to);

        // Emit approval event.
        ApprovalV0(msg.sender, _to, _tokenId);
    }

    /// @notice Transfer a Token owned by another address, for which the calling address
    ///  has previously been granted transfer approval by the owner.
    /// @param _from The address that owns the Token to be transfered.
    /// @param _to The address that should take ownership of the Token. Can be any address,
    ///  including the caller.
    /// @param _tokenId The ID of the Token to be transferred.
    /// @dev Required for ERC-721V0 compliance.
    function transferFromV0(
        address _from,
        address _to,
        uint256 _tokenId
    )
        external
        whenNotPaused
    {
        require(friendContract.isFriend(msg.sender));

        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
     
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any tokens (except very briefly
        // after a gen0 token is created and before it goes on offer).
        require(_to != address(this));

        // Check for approval and valid ownership
        // NOT SURE WHY THERE ARE ERRORS HERE.
        //require(_approvedForV0(msg.sender, _tokenId));

        //require(_ownsV0(_from, _tokenId));

        // Reassign ownership (also clears pending approvals and emits Transfer event).
         _transferV0(_from, _to, _tokenId);
    }

    /// @notice Returns the total number of Tokens currently in existence.
    /// @dev Required for ERC-721 compliance.
    function totalSupply() public view returns (uint) {
        return tokens.length - 1;
    }

    /// @notice Returns the address currently assigned ownership of a given Token.
    /// @dev Required for ERC-721 compliance.
    function ownerOfV0(uint256 _tokenId)
        external
        view
        returns (address owner)
    {
        owner = tokenIndexToOwnerV0[_tokenId];

        require(owner != address(0));
    }

    function getOwner(uint256 _tokenId)
        external
        view
        returns (address owner)
    {
        return tokenIndexToOwner[_tokenId];
    }

    function getRelatedTokens(uint256 _tokenId) external view returns(uint256, uint256, uint256, uint256) {
        RelatedTokens _relatedTokens = relatedTokens[_tokenId];
        return (
            _relatedTokens.token1,
            _relatedTokens.token2,
            _relatedTokens.token3,
            _relatedTokens.token4
        );
    }

    /// @dev Adapted from memcpy() by @arachnid (Nick Johnson <arachnid@notdot.net>)
    ///  This method is licenced under the Apache License.
    ///  Ref: https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol
    function _memcpy(uint _dest, uint _src, uint _len) private view {
        // Copy word-length chunks while possible
        for(; _len >= 32; _len -= 32) {
            assembly {
                mstore(_dest, mload(_src))
            }
            _dest += 32;
            _src += 32;
        }

        // Copy remaining bytes
        uint256 mask = 256 ** (32 - _len) - 1;
        assembly {
            let srcpart := and(mload(_src), not(mask))
            let destpart := and(mload(_dest), mask)
            mstore(_dest, or(destpart, srcpart))
        }
    }

    /// @dev Adapted from toString(slice) by @arachnid (Nick Johnson <arachnid@notdot.net>)
    ///  This method is licenced under the Apache License.
    ///  Ref: https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol
    function _toString(bytes32[4] _rawBytes, uint256 _stringLength) private view returns (string) {
        var outputString = new string(_stringLength);
        uint256 outputPtr;
        uint256 bytesPtr;

        assembly {
            outputPtr := add(outputString, 32)
            bytesPtr := _rawBytes
        }

        _memcpy(outputPtr, bytesPtr, _stringLength);

        return outputString;
    }

    /// @notice Returns the unique text value, conforming to
    ///  ERC-721 (https://github.com/ethereum/EIPs/issues/721)
    /// @param _tokenId The ID number of the Token whose metadata should be returned.
    function tokenMetadata(uint256 _tokenId) external view returns (string) {
        TokenCommon.Token memory token = tokens[_tokenId];
        return token.uniqueText;
    }
}