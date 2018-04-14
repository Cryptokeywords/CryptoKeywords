pragma solidity ^0.4.14;

import "./Pausable.sol";
import "./ClockOfferBase.sol";
import "./FriendContract.sol";

/// @title Clock offer for non-fungible tokens.
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract ClockOffer is Pausable, ClockOfferBase {
    FriendContract friendContract;

    /// @dev The ERC-165 interface signature for ERC-721.
    ///  Ref: https://github.com/ethereum/EIPs/issues/165
    ///  Ref: https://github.com/ethereum/EIPs/issues/721
    /// bytes4 constant InterfaceSignature_ERC721 = bytes4(0x9a20483d);

    /// @dev Constructor creates a reference to the NFT ownership contract
    ///  and verifies the owner cut is in the valid range.
    /// @param _erc721V0Address - address of a deployed contract implementing
    ///  the Nonfungible Interface.
    function ClockOffer(address _erc721V0Address, address _friendContract) public {
        ERC721V0 candidateContract = ERC721V0(_erc721V0Address);
        //require(candidateContract.supportsInterface(InterfaceSignature_ERC721));
        erc721V0 = candidateContract;
        friendContract = FriendContract(_friendContract);
    }

    /// @dev Remove all Ether from the contract, which is the owner's cuts
    ///  as well as any Ether sent directly to the contract address.
    ///  Always transfers to the NFT contract, but can be called either by
    ///  the owner or the NFT contract.
    function withdrawBalance() external {
        address nftAddress = address(erc721V0);

        require(
            msg.sender == owner ||
            msg.sender == nftAddress
        );
        // We are using this boolean method to make sure that even if one fails it will still work
        bool res = nftAddress.send(this.balance);
    }

    /// @dev Creates and begins a new offer.
    /// @param _tokenId - ID of token to offer, sender must be owner.
    /// @param _price - Price of item (in wei).
    /// @param _seller - Seller, if not the message sender
    function createOffer(
        uint256 _tokenId,
        uint256 _price,
        address _seller
    )
        public
        whenNotPaused
    {
        require(friendContract.isFriend(msg.sender));
        
        // Sanity check that no inputs overflow how many bits we've allocated
        // to store them in the offer struct.
        require(_price == uint256(uint128(_price)));

        require(_owns(msg.sender, _tokenId));
        _escrow(msg.sender, _tokenId);
        Offer memory offer = Offer(
            _seller,
            uint128(_price),
            uint64(now)
        );
        _addOffer(_tokenId, offer);
    }

    /// @dev Buys on an open offer, completing the offer and transferring
    ///  ownership of the NFT if enough Ether is supplied.
    /// @param _tokenId - ID of token to buy on.
    // function buy(uint256 _tokenId, uint256 _buyAmount)
    //     external
    //     payable
    //     whenNotPaused
    // {
    //     // _buy will throw if the buy or funds transfer fails
    //     _buy(_tokenId, _buyAmount);
    //     _transfer(msg.sender, _tokenId);
    // }

    /// @dev Returns offer info for an NFT on offer.
    /// @param _tokenId - ID of NFT on offer.
    function getOffer(uint256 _tokenId)
        external
        view
        returns
    (
        address seller,
        uint256 price,
        uint256 startedAt
    ) {
        Offer storage offer = tokenIdToOffer[_tokenId];
        require(_isOnOffer(offer));
        return (
            offer.seller,
            offer.price,
            offer.startedAt
        );
    }

    /// @dev Returns the current price of an offer.
    /// @param _tokenId - ID of the token price we are checking.
    function getCurrentPrice(uint256 _tokenId)
        external
        view
        returns (uint256)
    {
        Offer storage offer = tokenIdToOffer[_tokenId];
        require(_isOnOffer(offer));
        return offer.price;
    }

    function transferOffer(uint256 _tokenId, address newSeller) public {
        require(friendContract.isFriend(msg.sender));

        Offer storage offer = tokenIdToOffer[_tokenId];
        uint256 price = offer.price;
        _removeOffer(_tokenId);
        createOffer(
            _tokenId,
            price,
            newSeller
        );
    }
}
