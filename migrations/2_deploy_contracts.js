var FriendContract = artifacts.require("./FriendContract.sol");
var TokenCore = artifacts.require("./TokenCore.sol");
var SaleClockOffer = artifacts.require("./SaleClockOffer.sol");
var TokenIndex = artifacts.require("./TokenIndex.sol");
var TokenERC721 = artifacts.require("./TokenERC721.sol");
var TokenMinting = artifacts.require("./TokenMinting.sol");
var TokenIdentity = artifacts.require("./TokenIdentity.sol");
var TokenContent = artifacts.require("./TokenContent.sol");
var TokenTags = artifacts.require("./TokenTags.sol");
var TokenFlags = artifacts.require("./TokenFlags.sol");

module.exports = function(deployer) {
  deployer.deploy(FriendContract)
  .then(function () {
    return deployer.deploy(TokenCore, FriendContract.address);
  })
  .then(function () {
   return deployer.deploy(SaleClockOffer, TokenCore.address, FriendContract.address);
  })
  .then(function () {
    return deployer.deploy(TokenIndex, FriendContract.address);
  })
  .then(function () {
    return deployer.deploy(TokenERC721, TokenCore.address, FriendContract.address);
  })
  .then(function () {
    return deployer.deploy(TokenMinting, TokenCore.address, SaleClockOffer.address, TokenIndex.address, TokenERC721.address, FriendContract.address);
  })
  .then(function () {
    return deployer.deploy(TokenIdentity, TokenCore.address, TokenIndex.address);
  })
  .then(function () {
    return deployer.deploy(TokenContent, TokenERC721.address);
  })
  .then(function () {
    return deployer.deploy(TokenTags);
  })
  .then(function () {
    return deployer.deploy(TokenFlags);
  })
  ;
};
