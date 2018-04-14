pragma solidity ^0.4.14;

import "./TokenAccessControl.sol";

contract FriendContract is TokenAccessControl {
    address tokenCore;
    address saleOffer;
    address tokenIndex;
    address tokenERC721;
    address tokenMinting;

    function FriendContract() public {
        // the creator of the contract is the initial CEO
        ceoAddress = msg.sender;

        // the creator of the contract is also the initial COO
        cooAddress = msg.sender;
    }

    function setCore(address _core) public onlyCEO {
        tokenCore = _core;
    }

    function setSale(address _saleOffer) public onlyCEO {
        saleOffer = _saleOffer;
    }

    function setIndex(address _index) public onlyCEO {
        tokenIndex = _index;
    }

    function setERC721(address _erc721) public onlyCEO {
        tokenERC721 = _erc721;
    }

    function setMinting(address _minting) public onlyCEO {
        tokenMinting = _minting;
    }

    function canUnpause() public view returns (bool) {
        if ((tokenCore == address(0))||
            (saleOffer == address(0))||
            (tokenIndex == address(0))||
            (tokenERC721 == address(0))||
            (tokenMinting == address(0))) {
            return false;
        }
        return true;
    }

    function isFriend(address _address) public view returns (bool) {
        return ((_address == tokenCore)||
            (_address == saleOffer)||
            (_address == tokenIndex)|| 
            (_address == tokenERC721)||
            (_address == tokenMinting));
    }
}