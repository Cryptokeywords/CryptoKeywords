pragma solidity ^0.4.14;

import "./ClockOffer.sol";

/// @title Clock offer modified for sale of tokens
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract SaleClockOffer is ClockOffer {

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right offer in our setSaleOfferAddress() call.
    bool public isSaleClockOffer = true;

    // Delegate constructor
    function SaleClockOffer(address _erc721V0Address, address _friendContractAddress) public
        ClockOffer(_erc721V0Address, _friendContractAddress) 
    {
            
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
    {
        require(friendContract.isFriend(msg.sender));

        // Sanity check that no inputs overflow how many bits we've allocated
        // to store them in the offer struct.
        require(_price == uint256(uint128(_price)));

        //require(msg.sender == address(erc721V0));

        _escrow(_seller, _tokenId);

        Offer memory offer = Offer(
            _seller,
            uint128(_price),
            uint64(now)
        );

        _addOffer(_tokenId, offer);
    }

    /// @dev Updates lastSalePrice if seller is the nft contract
    /// Otherwise, works the same as default buy method.
    /// Automatically creates new offer.
    function buy(uint256 _tokenId, address buyer, address registrar)
        external
        payable
        returns (uint256)
    {
        require(friendContract.isFriend(msg.sender));

        // _buy verifies token ID size
        uint256 price = _buy(_tokenId, msg.value, buyer, registrar);

        _transfer(buyer, _tokenId);

        return price;
    }

    function getSaleOffer(uint256 _tokenId) 
        public
        view
        returns (
            uint256 price,
            address seller)
    {
        Offer memory offer = tokenIdToOffer[_tokenId];
        price = offer.price;
        seller = offer.seller;
    }

    function getSeller(uint256 _tokenId)
        public
        view
        returns (
            address seller)
    {
        Offer memory offer = tokenIdToOffer[_tokenId];
        seller = offer.seller;
    }
}
