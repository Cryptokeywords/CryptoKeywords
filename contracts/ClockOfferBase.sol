pragma solidity ^0.4.14;

import "./ERC721V0.sol";

/// @title Offer Core
/// @dev Contains models, variables, and internal methods for the offer.
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract ClockOfferBase {

    // Represents an offer on an NFT
    struct Offer {
        // Current owner of NFT
        address seller;
        // Price (in wei)
        uint128 price;
        // Time when offer started
        // NOTE: 0 if this offer has been concluded
        uint64 startedAt;
    }

    // Reference to contract tracking NFT ownership
    ERC721V0 public erc721V0;

    // Map from token ID to their corresponding offer.
    mapping (uint256 => Offer) tokenIdToOffer;

    event OfferCreated(uint256 tokenId, uint256 price);
    event OfferSuccessful(uint256 tokenId, uint256 price, address winner);
    event OfferCancelled(uint256 tokenId);

    /// @dev Emited to trace debug messages
    event Trace(string message);

    /// @dev Returns true if the claimant owns the token.
    /// @param _claimant - Address claiming to own the token.
    /// @param _tokenId - ID of token whose ownership to verify.
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return (erc721V0.ownerOfV0(_tokenId) == _claimant);
    }

    /// @dev Escrows the NFT, assigning ownership to this contract.
    /// Throws if the escrow fails.
    /// @param _owner - Current owner address of token to escrow.
    /// @param _tokenId - ID of token whose approval to verify.
    function _escrow(address _owner, uint256 _tokenId) internal {
        // it will throw if transfer fails
        erc721V0.transferFromV0(_owner, this, _tokenId);
    }

    /// @dev Transfers an NFT owned by this contract to another address.
    /// Returns true if the transfer succeeds.
    /// @param _receiver - Address to transfer NFT to.
    /// @param _tokenId - ID of token to transfer.
    function _transfer(address _receiver, uint256 _tokenId) internal {
        // it will throw if transfer fails
        erc721V0.transferV0(_receiver, _tokenId);
    }

    /// @dev Adds an offer to the list of open offers. Also fires the
    ///  OfferCreated event.
    /// @param _tokenId The ID of the token to be put on offer.
    /// @param _offer Offer to add.
    function _addOffer(uint256 _tokenId, Offer _offer) internal {
        tokenIdToOffer[_tokenId] = _offer;

        OfferCreated(
            uint256(_tokenId),
            uint256(_offer.price)
        );
    }

    /// @dev Computes the price and transfers winnings.
    /// Does NOT transfer ownership of token.
    function _buy(uint256 _tokenId, uint256 _buyAmount, address buyer, address registrar)
        internal
        returns (uint256)
    {
        // Get a reference to the offer struct
        Offer storage offer = tokenIdToOffer[_tokenId];

        // Explicitly check that this offer is currently live.
        // (Because of how Ethereum mappings work, we can't just count
        // on the lookup above failing. An invalid _tokenId will just
        // return an offer object that is all zeros.)
        require(_isOnOffer(offer));

        // Check that the buy is equal to the current price
        uint256 price = offer.price;
        require(_buyAmount >= price);

        // Grab a reference to the seller before the offer struct
        // gets deleted.
        address seller = offer.seller;

        // The buy is good! Remove the offer before sending the fees
        // to the sender so we can't have a reentrancy attack.
        _removeOffer(_tokenId);

        // Transfer proceeds to seller (if there are any!)
        if (price > 0) {
            // Calculate the operator's cut.
            // (NOTE: _computeCut() is guaranteed to return a
            // value <= price, so this subtraction can't go negative.)
            uint256 operatorCut = price * _computeCut(price) / 10000;
            uint256 wordOwnerCut = price * _wordOwnerCut(_tokenId, price) / 10000;
            uint256 registrarCut = price * 100 / 10000;
            uint256 sellerProceeds = price - operatorCut - wordOwnerCut - registrarCut;

            // NOTE: Doing a transfer() in the middle of a complex
            // method like this is generally discouraged because of
            // reentrancy attacks and DoS attacks if the seller is
            // a contract with an invalid fallback function. We explicitly
            // guard against reentrancy attacks by removing the offer
            // before calling transfer(), and the only thing the seller
            // can DoS is the sale of their own asset! (And if it's an
            // accident, they can call cancelOffer(). )
            seller.transfer(sellerProceeds);

            // Distribute commissions
            _distributeCommissions(_tokenId, price);

            if (registrar != address(0)) {
                registrar.transfer(registrarCut);
            }
        }

        // Calculate any excess funds included with the buy. If the excess
        // is anything worth worrying about, transfer it back to buyer.
        // NOTE: We checked above that the buy amount is greater than or
        // equal to the price so this cannot underflow.
        uint256 buyExcess = _buyAmount - price;

        // Return the funds. Similar to the previous transfer, this is
        // not susceptible to a re-entry attack because the offer is
        // removed before any transfers occur.
        buyer.transfer(buyExcess);

        // Tell the world!
        OfferSuccessful(_tokenId, price, msg.sender);

        return price;
    }

    function _distributeCommissions(uint256 _tokenId, uint256 price) internal {
        uint256 relatedToken1;
        uint256 relatedToken2;
        uint256 relatedToken3;
        uint256 relatedToken4;
        (relatedToken1, relatedToken2, relatedToken3, relatedToken4) = erc721V0.getRelatedTokens(_tokenId);

        uint256 wordOwnerProceeds = _wordOwnerProceeds(price);
        if (relatedToken1 > 0) {
            address wordOwner1 = erc721V0.getOwner(relatedToken1);
            wordOwner1.transfer(wordOwnerProceeds);
        }
        if (relatedToken2 > 0) {
            address wordOwner2 = erc721V0.getOwner(relatedToken2);
            wordOwner2.transfer(wordOwnerProceeds);
        }
        if (relatedToken3 > 0) {
            address wordOwner3 = erc721V0.getOwner(relatedToken3);
            wordOwner3.transfer(wordOwnerProceeds);
        }
        if (relatedToken4 > 0) {
            address wordOwner4 = erc721V0.getOwner(relatedToken4);
            wordOwner4.transfer(wordOwnerProceeds);
        }
    }

    /// @dev Removes an offer from the list of open offers.
    /// @param _tokenId - ID of NFT on offer.
    function _removeOffer(uint256 _tokenId) internal {
        delete tokenIdToOffer[_tokenId];
    }

    /// @dev Returns true if the NFT is on offer.
    /// @param _offer - Offer to check.
    function _isOnOffer(Offer storage _offer) internal view returns (bool) {
        return (_offer.startedAt > 0);
    }

    /// @dev Computes owner's cut of a sale.
    /// @param _price - Sale price of NFT.
    function _computeCut(uint256 _price) internal pure returns (uint256) {
        // NOTE: We don't use SafeMath (or similar) in this function because
        //  all of our entry functions carefully cap the maximum values for
        //  currency (at 128-bits), and ownerCut <= 10000 (see the require()
        //  statement in the ClockOffer constructor). The result of this
        //  function is always guaranteed to be <= _price.
        uint256 ownerCut = 350;

        if (_price >= 5 ether) {
            ownerCut = 200;
        }
        if (_price < 5 ether) {
            ownerCut = 300;
        }
        if (_price < 2 ether) {
            ownerCut = 300;
        }
        if (_price < 500 finney) {
            ownerCut = 400;
        } 
        if (_price < 50 finney) {
            ownerCut = 500;
        } 

        return ownerCut;
    }

    function _wordOwnerCut(uint256 _tokenId, uint256 price) internal returns (uint256) {
        uint256 relatedToken1;
        uint256 relatedToken2;
        uint256 relatedToken3;
        uint256 relatedToken4;
        (relatedToken1, relatedToken2, relatedToken3, relatedToken4) = erc721V0.getRelatedTokens(_tokenId);

        uint256 wordOwnerCut = 0;

        if (relatedToken1 > 0) {
            wordOwnerCut = 100;
        }
        if (relatedToken2 > 0) {
            wordOwnerCut = 200;
        }
        if (relatedToken3 > 0) {
            wordOwnerCut = 300;
        }
        if (relatedToken4 > 0) {
            wordOwnerCut = 400;
        }

        return wordOwnerCut;
    }

    function _wordOwnerProceeds(uint256 _price) internal pure returns (uint256) {
        uint256 wordOwnerCut = 100;
        return _price * wordOwnerCut / 10000;
    }
}
