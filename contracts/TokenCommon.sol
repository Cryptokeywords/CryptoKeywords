pragma solidity ^0.4.17;

library TokenCommon {
    /// @dev The main Token struct. Every token in CryptoTokens is represented by a copy
    ///  of this structure, so great care was taken to ensure that it fits neatly into
    ///  exactly two 256-bit words. Note that the order of the members in this structure
    ///  is important because of the byte-packing rules used by Ethereum.
    ///  Ref: http://solidity.readthedocs.io/en/develop/miscellaneous.html
    struct Token {
        // The unique asset being tokenized.
        string uniqueText;

        // Identifies who created the token first.
        address firstOwner;

        // The timestamp from the block when this token came into existence.
        uint64 mintTime;

        // Identifies whether token is hidden
        bool isHidden;
    }
}