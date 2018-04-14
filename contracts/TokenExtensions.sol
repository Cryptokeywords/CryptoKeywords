pragma solidity ^0.4.14;

import "./FriendContract.sol";
import "./TokenAccessControl.sol";
import "./SaleClockOffer.sol";
import "./TokenIndex.sol";

/// @title Base contract for CryptoTokens. Holds all common structs, events and base variables.
/// @dev See the TokenCore contract documentation to understand how the various contract facets are arranged.
contract TokenExtensions is TokenAccessControl {
    /// @dev The address of the ClockOffer contract that handles sales of Tokens. This
    ///  same contract handles both peer-to-peer sales as well as the gen0 sales which are
    ///  initiated every 15 minutes.
    SaleClockOffer public saleOffer;

    TokenIndex public index;

    /// @dev Sets the reference to the sale offer.
    /// @param _address - Address of sale contract.
    function setSaleOfferAddress(address _address) external onlyCEO {
        SaleClockOffer candidateContract = SaleClockOffer(_address);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(candidateContract.isSaleClockOffer());

        // Set the new contract address
        saleOffer = candidateContract;
    }

    function setTokenIndexAddress(address _address) external onlyCEO {
        index = TokenIndex(_address);
    }
}