pragma solidity ^0.4.14;

import "./TokenOffer.sol";

/// @title all functions related to creating tokens
contract TokenMinting is TokenOffer {
    // Limits the number of cats the contract owner can ever create.
    uint256 public constant PROMO_CREATION_LIMIT = 5000;

    // Constants for gen0 offers.
    uint256 public constant STARTING_PRICE = 1 finney;

    // Counts the number of cats the contract owner has created.
    uint256 public promoCreatedCount;

    // Counts the number of cats created by others.
    uint256 public othersCreatedCount;

    bool public mintingAllowed = false;

    // @notice The offer contract variables are defined in TokenBase to allow
    //  us to refer to them in TokenOwnership to prevent accidental transfers.
    // `saleOffer` refers to the offer for gen0 and p2p sale of tokens.


    // Delegate constructor
    function TokenMinting(
        address _tokenCoreAddress, 
        address _saleOfferAddress,
        address _tokenIndexAddress,
        address _tokenERC721Address,
        address _friendContract) public
    {
        core = TokenCore(_tokenCoreAddress);
        index = TokenIndex(_tokenIndexAddress);
        erc721 = TokenERC721(_tokenERC721Address);
        friendContract = FriendContract(_friendContract);

        SaleClockOffer candidateContract = SaleClockOffer(_saleOfferAddress);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(candidateContract.isSaleClockOffer());

        // Set the new contract address
        saleOffer = candidateContract;

        // Starts paused.
        paused = true;

        // the creator of the contract is the initial CEO
        ceoAddress = msg.sender;

        // the creator of the contract is also the initial COO
        cooAddress = msg.sender;
            
    }

    modifier whenMintingAllowed() {
        require(mintingAllowed);
        _;
    }

    modifier whenMintingNotAllowed() {
        require(!mintingAllowed);
        _;
    }

    event AllowMinting();
    function allowMinting() external onlyCLevel whenMintingNotAllowed {
        mintingAllowed = true;
        AllowMinting();
    }

    event DisallowMinting();
    function disallowMinting() public onlyCLevel whenMintingAllowed {
        mintingAllowed = false;
        DisallowMinting();
    }

    /// @dev we can create promo tokens, up to a limit. Only callable by COO
    /// @param _owner the future owner of the created tokens. Default to contract COO
    function createPromoToken(string _uniqueText, address _owner) 
        external
        onlyCOO 
    {
        address tokenOwner = _owner;
        if (tokenOwner == address(0)) {
            tokenOwner = cooAddress;
        }
        require(promoCreatedCount < PROMO_CREATION_LIMIT);

        uint256 tokenId = core.createToken(
            _uniqueText, 
            tokenOwner
        );
        
        core.approveV0(saleOffer, tokenId);

        saleOffer.createOffer(
            tokenId,
            STARTING_PRICE,
            tokenOwner
        );

        promoCreatedCount++;

        erc721.setFirstOwner(tokenId, tokenOwner);
    }

    event CreateNewToken(string _uniqueText, address registrar);
    
    /// @dev Creates a new gen0 token with the given genes and
    ///  creates an offer for it.
    function createNewToken(string _uniqueText, address _registrar) 
        external 
        payable
        whenMintingAllowed
    {
        uint256 tokenId = core.createToken(
            _uniqueText, 
            address(this)
        );

        core.approveV0(
            saleOffer, 
            tokenId
        );
                
        saleOffer.createOffer(
            tokenId,
            STARTING_PRICE,
            address(this)
        );

        uint256 price = saleOffer.buy.value(msg.value)(tokenId, msg.sender, _registrar);

        core.approveV0(
            saleOffer,
            tokenId
        );

        saleOffer.createOffer(
            tokenId,
            _updatePrice(price),
            msg.sender
        );

        index.firstTradeCheck();

        index.incrementTrades(tokenId);

        othersCreatedCount++;

        erc721.setFirstOwner(tokenId, msg.sender);

        CreateNewToken(_uniqueText, _registrar);
    }

    // function bytes32ToString(bytes32 x) constant returns (string) {
    //     bytes memory bytesString = new bytes(32);
    //     uint charCount = 0;
    //     for (uint j = 0; j < 32; j++) {
    //         byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
    //         if (char != 0) {
    //             bytesString[charCount] = char;
    //             charCount++;
    //         }
    //     }
    //     bytes memory bytesStringTrimmed = new bytes(charCount);
    //     for (j = 0; j < charCount; j++) {
    //         bytesStringTrimmed[j] = bytesString[j];
    //     }
    //     return string(bytesStringTrimmed);
    // }

    // function uintToBytes(uint v) constant returns (bytes32 ret) {
    //     if (v == 0) {
    //         ret = "0";
    //     } else {
    //         while (v > 0) {
    //             ret = bytes32(uint(ret) / (2 ** 8));
    //             ret |= bytes32(((v % 10) + 48) * 2 ** (8 * 31));
    //             v /= 10;
    //         }
    //     }
    //     return ret;
    // }

}
