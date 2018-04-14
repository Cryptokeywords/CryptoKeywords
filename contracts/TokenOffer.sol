pragma solidity ^0.4.14;

import "./TokenAccessControl.sol";
import "./SaleClockOffer.sol";
import "./TokenIndex.sol";
import "./TokenCore.sol";
import "./TokenERC721.sol";
import "./FriendContract.sol";

/// @title Handles creating offers for sale of tokens.
///  This wrapper of ReverseOffer exists only so that users can create
///  offers with only one transaction.
contract TokenOffer is TokenAccessControl {
    TokenCore public core;
    TokenIndex public index;
    SaleClockOffer public saleOffer;
    TokenERC721 public erc721;
    FriendContract public friendContract;

    /// @dev Override unpause so it requires all external contract addresses
    ///  to be set before contract can be unpaused. Also, we can't have
    ///  newContractAddress set either, because then the contract was upgraded.
    /// @notice This is public rather than external so we can call super.unpause
    ///  without using an expensive CALL.
    function unpause() public onlyCEO whenPaused {
        require(saleOffer != address(0));

        // Actually unpause the contract.
        super.unpause();
    }

    /// @notice No tipping!
    /// @dev Reject all Ether from being sent here, unless it's from one of the
    ///  two offer contracts. (Hopefully, we can prevent user accidents.)
    function() external payable {
        require(
            msg.sender == address(saleOffer)
        );
    }
    
    /// NOT TO BE USED. OFFERS ARE AUTOMATICALLY CREATED.
    /// @dev Put a token up for offer.
    ///  Does some ownership trickery to create offers in one tx.
    function _createSaleOffer(
        uint256 _tokenId,
        uint256 _price
    )
        internal
        whenNotPaused
    {
        // Offer contract checks input sizes
        // If token is already on any offer, this will throw
        // because it will be owned by the offer contract.
        require(core.ownsV0(
            msg.sender, 
            _tokenId
            ));

        core.approveV0(
            saleOffer,
            _tokenId
        );
        
        // Sale offer throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the token.
        saleOffer.createOffer(
            _tokenId,
            _price,
            msg.sender
        );
    }

    function buy(uint256 tokenId, address registrar) 
        public
        payable
    {
        address seller = saleOffer.getSeller(tokenId);
        uint256 price = saleOffer.buy.value(msg.value)(tokenId, msg.sender, registrar);
        index.incrementTrades(tokenId);

        core.approveV0(
            saleOffer,
            tokenId
        );

        saleOffer.createOffer(
            tokenId,
            _updatePrice(price),
            msg.sender
        );

        erc721.setNewOwner(tokenId, seller, msg.sender);
    }

    function _updatePrice(uint256 _price) 
        internal 
        pure 
        returns (uint256)
    {
        if (_price < 50 finney) {
            return _price * 2;
        } 
        if (_price < 500 finney) {
            return _price * 135 / 100;
        } 
        if (_price < 2 ether) {
            return _price * 125 / 100;
        }
        if (_price < 5 ether) {
            return _price * 117 / 100;
        }
        if (_price >= 5 ether) {
            return _price * 115 / 100;
        }

        return _price;
    }

    function getSaleOffer(uint256 _tokenId) 
        public
        view
        returns (
            uint256 price,
            address seller)
    {
        (price, seller) = saleOffer.getSaleOffer(_tokenId);
    }

    function getSaleOfferBalance() 
        public
        view
        returns (
            uint256 balance)
    {
        return saleOffer.balance;
    }
}
