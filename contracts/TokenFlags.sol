pragma solidity ^0.4.14;

import "./TokenAccessControl.sol";

/// @title Content extension of Token
contract TokenFlags is TokenAccessControl {
    struct Flags {
        bool flag01;
        bool flag02;
        bool flag03;
        bool flag04;
        bool flag05;
        bool flag06;
        bool flag07;
        bool flag08;
        bool flag09;
        bool flag10;
        bool flag11;
        bool flag12;
        bool flag13;
        bool flag14;
        bool flag15;
        bool flag16;
        bool flag17;
        bool flag18;
        bool flag19;
        bool flag20;
    }

    mapping(string => Flags) userFlags;
    mapping(string => Flags) adminFlags;

    function TokenFlags() {
        // the creator of the contract is the initial CEO
        ceoAddress = msg.sender;

        // the creator of the contract is also the initial COO
        cooAddress = msg.sender;
    }

    /// @notice No tipping!
    /// @dev Reject all Ether from being sent here.
    /// (Hopefully, we can prevent user accidents.)
    function() external payable {
        require(false);
    }

    function getUserFlagsA(
        string _metadata) external 
        view
        returns 
        (
            bool flag01,
            bool flag02,
            bool flag03,
            bool flag04,
            bool flag05,
            bool flag06,
            bool flag07,
            bool flag08,
            bool flag09,
            bool flag10
        ) {
        Flags storage flag = userFlags[_metadata];
        flag01 = flag.flag01;
        flag02 = flag.flag02;
        flag03 = flag.flag03;
        flag04 = flag.flag04;
        flag05 = flag.flag05;
        flag06 = flag.flag06;
        flag07 = flag.flag07;
        flag08 = flag.flag08;
        flag09 = flag.flag09;
        flag10 = flag.flag10;
    }

    function getUserFlagsB(
        string _metadata) external 
        view
        returns 
        (
            bool flag11,
            bool flag12,
            bool flag13,
            bool flag14,
            bool flag15,
            bool flag16,
            bool flag17,
            bool flag18,
            bool flag19,
            bool flag20
        ) {
        Flags storage flag = userFlags[_metadata];
        flag11 = flag.flag11;
        flag12 = flag.flag12;
        flag13 = flag.flag13;
        flag14 = flag.flag14;
        flag15 = flag.flag15;
        flag16 = flag.flag16;
        flag17 = flag.flag17;
        flag18 = flag.flag18;
        flag19 = flag.flag19;
        flag20 = flag.flag20;
    }

    function getAdminFlagsA(
        string _metadata) external 
        view
        onlyCLevel
        returns 
        (
            bool flag01,
            bool flag02,
            bool flag03,
            bool flag04,
            bool flag05,
            bool flag06,
            bool flag07,
            bool flag08,
            bool flag09,
            bool flag10
        ) {
        Flags storage flag = adminFlags[_metadata];
        flag01 = flag.flag01;
        flag02 = flag.flag02;
        flag03 = flag.flag03;
        flag04 = flag.flag04;
        flag05 = flag.flag05;
        flag06 = flag.flag06;
        flag07 = flag.flag07;
        flag08 = flag.flag08;
        flag09 = flag.flag09;
        flag10 = flag.flag10;
    }

    function getAdminFlagsB(
        string _metadata) external 
        view
        onlyCLevel
        returns 
        (
            bool flag11,
            bool flag12,
            bool flag13,
            bool flag14,
            bool flag15,
            bool flag16,
            bool flag17,
            bool flag18,
            bool flag19,
            bool flag20
        ) {
        Flags storage flag = adminFlags[_metadata];
        flag11 = flag.flag11;
        flag12 = flag.flag12;
        flag13 = flag.flag13;
        flag14 = flag.flag14;
        flag15 = flag.flag15;
        flag16 = flag.flag16;
        flag17 = flag.flag17;
        flag18 = flag.flag18;
        flag19 = flag.flag19;
        flag20 = flag.flag20;
    }

    // users can only set flags to true
    function setUserFlagsTrue(string _metadata, uint _i) 
        external
    {
        Flags storage flag = userFlags[_metadata];
        if (_i == 1) {
            flag.flag01 = true;
        }
        if (_i == 2) {
            flag.flag02 = true;
        }
        if (_i == 3) {
            flag.flag03 = true;
        }
        if (_i == 4) {
            flag.flag04 = true;
        }
        if (_i == 5) {
            flag.flag05 = true;
        }
        if (_i == 6) {
            flag.flag06 = true;
        }
        if (_i == 7) {
            flag.flag07 = true;
        }
        if (_i == 8) {
            flag.flag08 = true;
        }
        if (_i == 9) {
            flag.flag09 = true;
        }
        if (_i == 10) {
            flag.flag10 = true;
        }
        if (_i == 11) {
            flag.flag11 = true;
        }
        if (_i == 12) {
            flag.flag12 = true;
        }
        if (_i == 13) {
            flag.flag13 = true;
        }
        if (_i == 14) {
            flag.flag14 = true;
        }
        if (_i == 15) {
            flag.flag15 = true;
        }
        if (_i == 16) {
            flag.flag16 = true;
        }
        if (_i == 17) {
            flag.flag17 = true;
        }
        if (_i == 18) {
            flag.flag19 = true;
        }
        if (_i == 19) {
            flag.flag19 = true;
        }
        if (_i == 20) {
            flag.flag20 = true;
        }

        userFlags[_metadata] = flag;
    }

    function setUserFlags(string _metadata, uint _i, uint valueNumber) 
        external
        onlyCLevel
    {
        bool value = false;
        if (valueNumber > 0) {
            value = true;
        }
        Flags storage flag = userFlags[_metadata];
        if (_i == 1) {
            flag.flag01 = value;
        }
        if (_i == 2) {
            flag.flag02 = value;
        }
        if (_i == 3) {
            flag.flag03 = value;
        }
        if (_i == 4) {
            flag.flag04 = value;
        }
        if (_i == 5) {
            flag.flag05 = value;
        }
        if (_i == 6) {
            flag.flag06 = value;
        }
        if (_i == 7) {
            flag.flag07 = value;
        }
        if (_i == 8) {
            flag.flag08 = value;
        }
        if (_i == 9) {
            flag.flag09 = value;
        }
        if (_i == 10) {
            flag.flag10 = value;
        }
        if (_i == 11) {
            flag.flag11 = value;
        }
        if (_i == 12) {
            flag.flag12 = value;
        }
        if (_i == 13) {
            flag.flag13 = value;
        }
        if (_i == 14) {
            flag.flag14 = value;
        }
        if (_i == 15) {
            flag.flag15 = value;
        }
        if (_i == 16) {
            flag.flag16 = value;
        }
        if (_i == 17) {
            flag.flag17 = value;
        }
        if (_i == 18) {
            flag.flag19 = value;
        }
        if (_i == 19) {
            flag.flag19 = value;
        }
        if (_i == 20) {
            flag.flag20 = value;
        }

        userFlags[_metadata] = flag;
    }

    function setAdminFlags(string _metadata, uint _i, uint valueNumber) 
        external
        onlyCLevel
    {
        bool value = false;
        if (valueNumber > 0) {
            value = true;
        }
        Flags storage flag = adminFlags[_metadata];
        if (_i == 1) {
            flag.flag01 = value;
        }
        if (_i == 2) {
            flag.flag02 = value;
        }
        if (_i == 3) {
            flag.flag03 = value;
        }
        if (_i == 4) {
            flag.flag04 = value;
        }
        if (_i == 5) {
            flag.flag05 = value;
        }
        if (_i == 6) {
            flag.flag06 = value;
        }
        if (_i == 7) {
            flag.flag07 = value;
        }
        if (_i == 8) {
            flag.flag08 = value;
        }
        if (_i == 9) {
            flag.flag09 = value;
        }
        if (_i == 10) {
            flag.flag10 = value;
        }
        if (_i == 11) {
            flag.flag11 = value;
        }
        if (_i == 12) {
            flag.flag12 = value;
        }
        if (_i == 13) {
            flag.flag13 = value;
        }
        if (_i == 14) {
            flag.flag14 = value;
        }
        if (_i == 15) {
            flag.flag15 = value;
        }
        if (_i == 16) {
            flag.flag16 = value;
        }
        if (_i == 17) {
            flag.flag17 = value;
        }
        if (_i == 18) {
            flag.flag19 = value;
        }
        if (_i == 19) {
            flag.flag19 = value;
        }
        if (_i == 20) {
            flag.flag20 = value;
        }

        adminFlags[_metadata] = flag;
    }
}