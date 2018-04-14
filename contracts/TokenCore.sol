pragma solidity ^0.4.14;

import "./TokenCommon.sol";
//import "./TokenMinting.sol";
import "./TokenOwnership.sol";

/// @title CryptoTokens: Collectible tokens on the Ethereum blockchain.
/// @dev The main CryptoTokens contract, keeps track of tokens so they don't wander around and get lost.
contract TokenCore is TokenOwnership {

    // This is the main CryptoTokens contract. In order to keep our code seperated into logical sections,
    // we've broken it up in two ways. First, we have several seperately-instantiated sibling contracts
    // that handle offers. The offers are
    // separate since their logic is somewhat complex and there's always a risk of subtle bugs. By keeping
    // them in their own contracts, we can upgrade them without disrupting the main contract that tracks
    // token ownership.
    //
    // Secondly, we break the core contract into multiple files using inheritence, one for each major
    // facet of functionality of CKW. This allows us to keep related code bundled together while still
    // avoiding a single giant file with everything in it. The breakdown is as follows:
    //
    //      - TokenBase: This is where we define the most fundamental code shared throughout the core
    //             functionality. This includes our main data storage, constants and data types, plus
    //             internal functions for managing these items.
    //
    //      - TokenAccessControl: This contract manages the various addresses and constraints for operations
    //             that can be executed only by specific roles. Namely CEO, CFO and COO.
    //
    //      - TokenOwnership: This provides the methods required for basic non-fungible token
    //             transactions, following the draft ERC-721 spec (https://github.com/ethereum/EIPs/issues/721).
    //
    //      - TokenOffer: Here we have the public methods for offering or buying on tokens
    //             The actual offer functionality is handled in sibling contracts,
    //             while offer creation and buying is mostly mediated
    //             through this facet of the core contract.
    //
    //      - TokenMinting: This final facet contains the functionality we use for creating new tokens.
    //             We can make up to 5000 "promo" tokens that can be given away (especially important when
    //             the community is new), and all others can only be created and then immediately put up
    //             for offer via an algorithmically determined starting price. Regardless of how they
    //             are created, there is a hard limit of 50k tokens. After that, it's all up to the
    //             community to mint, mint, mint!

    // Set in case the core contract is broken and an upgrade is required
    address public newContractAddress;

    /// @notice Creates the main CryptoTokens smart contract instance.
    function TokenCore(address _friendContract) public
        TokenBase(_friendContract) 
    {
        // Starts paused.
        paused = true;

        // the creator of the contract is the initial CEO
        ceoAddress = msg.sender;

        // the creator of the contract is also the initial COO
        cooAddress = msg.sender;

        _addToken0();
    }

    /// @dev Avoids having an actual token with ID 0.
    function _addToken0() internal {
        TokenCommon.Token memory _tokenItem = TokenCommon.Token({
            uniqueText: "",
            firstOwner: address(0),
            mintTime: uint64(now),
            isHidden: false
        });
        tokens.push(_tokenItem);
    }

    /// @dev Used to mark the smart contract as upgraded, in case there is a serious
    ///  breaking bug. This method does nothing but keep track of the new contract and
    ///  emit a message indicating that the new address is set. It's up to clients of this
    ///  contract to update to the new contract address in that case. (This contract will
    ///  be paused indefinitely if such an upgrade takes place.)
    /// @param _v2Address new address
    function setNewAddress(address _v2Address) external onlyCEO whenPaused {
        // See README.md for updgrade plan
        newContractAddress = _v2Address;
        ContractUpgrade(_v2Address);
    }

    /// @notice No tipping!
    /// @dev Reject all Ether from being sent here.
    /// (Hopefully, we can prevent user accidents.)
    function() external payable {
        require(msg.sender == address(saleOffer));
    }
    
    /// @dev Override unpause so it requires all external contract addresses
    ///  to be set before contract can be unpaused. Also, we can't have
    ///  newContractAddress set either, because then the contract was upgraded.
    /// @notice This is public rather than external so we can call super.unpause
    ///  without using an expensive CALL.
    function unpause() public onlyCEO whenPaused {
        require(friendContract.canUnpause());
        require(address(saleOffer) != address(0));
        require(address(index) != address(0));
        require(newContractAddress == address(0));

        // Actually unpause the contract.
        super.unpause();
    }

    function getBalance() 
        public
        view
        returns (
            uint256 balance)
    {
        return this.balance;
    }

    // @dev Allows the CFO to capture the balance available to the contract.
    function withdrawBalance() external onlyCFO {
        uint256 balance = this.balance;

        if (balance > 0) {
            cfoAddress.send(balance);
        }
    }

    /// @dev Transfers the balance of the sale offer contract
    /// to the TokenOffer contract. We use two-step withdrawal to
    /// prevent two transfer calls in the offer buy function.
    function withdrawOfferBalances() external onlyCLevel {
        saleOffer.withdrawBalance();
    }
    
    /// @notice Returns all the relevant information about a specific token.
    /// @param _id The ID of the token of interest.
    function getToken(uint256 _id)
        external
        view
        returns (
        uint256 mintTime,
        uint256 price,
        uint256 trades) 
    {
        TokenCommon.Token storage kit = tokens[_id];

        mintTime = uint256(kit.mintTime);
        address seller;
        (price, seller) = saleOffer.getSaleOffer(_id);
        trades = index.getTrades(_id);
    }

    function getUniqueText(uint256 _id) external view returns (string) {
        return tokens[_id].uniqueText;
    }
    
    function isHidden(uint256 _id) external view returns (bool) {
        return tokens[_id].isHidden;
    }

    function transferOffer(uint256 _tokenId, address _newSeller) public {
        require(friendContract.isFriend(msg.sender));
        approveV0(saleOffer, _tokenId);
        saleOffer.transferOffer(_tokenId, _newSeller);
    }
}
