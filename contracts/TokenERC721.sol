pragma solidity ^0.4.14;

import "./ERC721.sol";
import "./TokenAccessControl.sol";
import "./ERC721Metadata.sol";
import "./SaleClockOffer.sol";
import "./TokenCore.sol";
import "./FriendContract.sol";

/// @title The facet of the CryptoTokens core contract that manages ownership, ERC-721 (draft) compliant.
/// @dev Ref: https://github.com/ethereum/EIPs/issues/721
///  See the TokenCore contract documentation to understand how the various contract facets are arranged.
contract TokenERC721 is ERC721, TokenAccessControl {
    TokenCore core;
    FriendContract friendContract;

    // Delegate constructor
    function TokenERC721(address _core, address _friendContract) public {
        core = TokenCore(_core);
        friendContract = FriendContract(_friendContract);

        // the creator of the contract is the initial CEO
        ceoAddress = msg.sender;

        // the creator of the contract is also the initial COO
        cooAddress = msg.sender;
    }
    
    event Transfer(address from, address to, uint256 tokenId);

    /// @dev A mapping from token IDs to the address that owns them. All tokens have
    ///  some valid owner address, even gen0 tokens are created with a non-zero owner.
    mapping (uint256 => address) public tokenIndexToOwner;

    // @dev A mapping from owner address to count of tokens that address owns.
    //  Used internally inside balanceOf() to resolve ownership count.
    mapping (address => uint256) ownershipTokenCount;

    /// @dev A mapping from TokenIDs to an address that has been approved to call
    ///  transferFrom(). Each Token can only have one approved address for transfer
    ///  at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public tokenIndexToApproved;

    // The contract that will return token metadata
    ERC721Metadata public erc721Metadata;

    bytes4 constant InterfaceSignature_ERC165 =
        bytes4(keccak256("supportsInterface(bytes4)"));

    bytes4 constant InterfaceSignature_ERC721 =
        bytes4(keccak256("name()")) ^
        bytes4(keccak256("symbol()")) ^
        bytes4(keccak256("totalSupply()")) ^
        bytes4(keccak256("balanceOf(address)")) ^
        bytes4(keccak256("ownerOf(uint256)")) ^
        bytes4(keccak256("approve(address,uint256)")) ^
        bytes4(keccak256("transfer(address,uint256)")) ^
        bytes4(keccak256("transferFrom(address,address,uint256)")) ^
        bytes4(keccak256("tokensOfOwner(address)")) ^
        bytes4(keccak256("tokenMetadata(uint256,string)"));

    /// @notice Introspection interface as per ERC-165 (https://github.com/ethereum/EIPs/issues/165).
    ///  Returns true for any standardized interfaces implemented by this contract. We implement
    ///  ERC-165 (obviously!) and ERC-721.
    function supportsInterface(bytes4 _interfaceID) 
        external 
        view 
        returns (
            bool
        ) {
        // DEBUG ONLY
        //require((InterfaceSignature_ERC165 == 0x01ffc9a7) && (InterfaceSignature_ERC721 == 0x9a20483d));

        return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC721));
    }
        
    /// @dev Assigns ownership of a specific Token to an address.
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        // Since the number of tokens is capped to 2^32 we can't overflow this
        ownershipTokenCount[_to]++;
        // transfer ownership
        tokenIndexToOwner[_tokenId] = _to;
        core.setOwner(_tokenId, _to);

        // When creating new tokens _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
            // clear any previously approved ownership exchange
            delete tokenIndexToApproved[_tokenId];
        }
        // Emit the transfer event.
        Transfer(_from, _to, _tokenId);
    }

    /// @dev Set the address of the sibling contract that tracks metadata.
    ///  CEO only.
    function setMetadataAddress(address _contractAddress) public onlyCEO {
        erc721Metadata = ERC721Metadata(_contractAddress);
    }

    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return tokenIndexToOwner[_tokenId] == _claimant;
    }

    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return tokenIndexToApproved[_tokenId] == _claimant;
    }

    function _approve(uint256 _tokenId, address _approved) internal {
        tokenIndexToApproved[_tokenId] = _approved;
    }

    function totalSupply() public view returns (uint) {
        return core.totalSupply();
    }

    /// @notice Returns the number of Tokens owned by a specific address.
    /// @param _owner The owner address to check.
    /// @dev Required for ERC-721 compliance
    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }

    /// @notice Returns the address currently assigned ownership of a given Token.
    /// @dev Required for ERC-721 compliance.
    function ownerOf(uint256 _tokenId)
        external
        view
        returns (address owner)
    {
        owner = tokenIndexToOwner[_tokenId];

        require(owner != address(0));
    }

    /// @notice Grant another address the right to transfer a specific Token via
    ///  transferFrom(). This is the preferred flow for transfering NFTs to contracts.
    /// @param _to The address to be granted transfer approval. Pass address(0) to
    ///  clear all approvals.
    /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.
    /// @dev Required for ERC-721 compliance.
    function approve(
        address _to,
        uint256 _tokenId
    )
        external
        whenNotPaused
    {
        // Only an owner can grant transfer approval.
        require(_owns(msg.sender, _tokenId));

        // Register the approval (replacing any previous approval).
        _approve(_tokenId, _to);

        // Emit approval event.
        Approval(msg.sender, _to, _tokenId);
    }

    function transfer(
        address _to,
        uint256 _tokenId
    )
        external
        whenNotPaused
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any tokens (except very briefly
        // after a gen0 token is created and before it goes on offer).
        require(_to != address(this));

        // You can only send your own token.
        require(_owns(msg.sender, _tokenId));

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _transfer(msg.sender, _to, _tokenId);

        core.transferOffer(_tokenId, _to);
    }
    
    function forceTransfer(
        address _from,
        address _to,
        uint256 _tokenId
    )
        external
        whenNotPaused
        onlyCLevel
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any tokens (except very briefly
        // after a gen0 token is created and before it goes on offer).
        require(_to != address(this));

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _transfer(_from, _to, _tokenId);

        core.transferOffer(_tokenId, _to);
    }

    /// @notice Transfer a Token owned by another address, for which the calling address
    ///  has previously been granted transfer approval by the owner.
    /// @param _from The address that owns the Token to be transfered.
    /// @param _to The address that should take ownership of the Token. Can be any address,
    ///  including the caller.
    /// @param _tokenId The ID of the Token to be transferred.
    /// @dev Required for ERC-721V0 compliance.
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        external
        whenNotPaused
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
     
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any tokens (except very briefly
        // after a gen0 token is created and before it goes on offer).
        require(_to != address(this));

        // Check for approval and valid ownership
        require(_approvedFor(msg.sender, _tokenId));

        require(_owns(_from, _tokenId));

        // Reassign ownership (also clears pending approvals and emits Transfer event).
        _transfer(_from, _to, _tokenId);

        core.transferOffer(_tokenId, _to);
    }

    /// @notice Name and symbol of the non fungible token, as defined in ERC721.
    function name() 
        public 
        view 
        returns (
            string
        ) {
        return "CryptoKeywords";
    }

    function symbol() 
        public 
        view 
        returns (
            string
        ) {
        return "CKW";
    }

    /// @notice Returns the unique text value, conforming to
    ///  ERC-721 (https://github.com/ethereum/EIPs/issues/721)
    /// @param _tokenId The ID number of the Token whose metadata should be returned.
    function tokenMetadata(uint256 _tokenId) external view returns (string) {
        /// string memory metadata = core.tokenMetadata(_tokenId);
        /// return metadata;
        return "";
    }

    function myTokens() external view returns(uint256[] ownerTokens) {
        address _owner = msg.sender;
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalTokens = core.totalSupply();
            uint256 resultIndex = 0;

            // We count on the fact that all tokens have IDs starting at 1 and increasing
            // sequentially up to the totalToken count.
            uint256 tokenId;

            for (tokenId = 1; tokenId <= totalTokens; tokenId++) {
                if (tokenIndexToOwner[tokenId] == _owner) {
                    result[resultIndex] = tokenId;
                    resultIndex++;
                }
            }

            return result;
        }
    }

    /// @notice Returns a list of all Token IDs assigned to an address.
    /// @param _owner The owner whose Tokens we are interested in.
    /// @dev This method MUST NEVER be called by smart contract code. First, it's fairly
    ///  expensive (it walks the entire Token array looking for tokens belonging to owner),
    ///  but it also returns a dynamic array, which is only supported for web3 calls, and
    ///  not contract-to-contract calls.
    function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalTokens = core.totalSupply();
            uint256 resultIndex = 0;

            // We count on the fact that all tokens have IDs starting at 1 and increasing
            // sequentially up to the totalToken count.
            uint256 tokenId;

            for (tokenId = 1; tokenId <= totalTokens; tokenId++) {
                if (tokenIndexToOwner[tokenId] == _owner) {
                    result[resultIndex] = tokenId;
                    resultIndex++;
                }
            }

            return result;
        }
    }

    function setFirstOwner(
        uint256 _tokenId,
        address _owner)
    public 
    {
        require(friendContract.isFriend(msg.sender));
        ownershipTokenCount[_owner]++;
        tokenIndexToOwner[_tokenId] = _owner;
        core.setOwner(_tokenId, _owner);
    }

    function setNewOwner(
        uint256 _tokenId,
        address _seller,
        address _buyer)
    public 
    {
        require(friendContract.isFriend(msg.sender));
        _transfer(_seller, _buyer, _tokenId);
    }

    function isOwned(uint256 _tokenId)
    public
    view
    returns (bool) {
        return (tokenIndexToOwner[_tokenId] == msg.sender);
    }
}