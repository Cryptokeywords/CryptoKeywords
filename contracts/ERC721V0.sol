pragma solidity ^0.4.14;

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <dete@axiomzen.co> (https://github.com/dete)
contract ERC721V0 {
    // Required methods
    // function totalSupply() public view returns (uint256 total);
    // function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOfV0(uint256 _tokenId) external view returns (address owner);
    function getOwner(uint256 _tokenId) external view returns (address owner);
    function approveV0(address _to, uint256 _tokenId) public;
    function transferV0(address _to, uint256 _tokenId) external;
    function transferFromV0(address _from, address _to, uint256 _tokenId) external;
    function getRelatedTokens(uint256 _tokenId) external view returns(uint256, uint256, uint256, uint256);

    // Events
    event TransferV0(address from, address to, uint256 tokenId);
    event ApprovalV0(address owner, address approved, uint256 tokenId);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    // function supportsInterfaceV0(bytes4 _interfaceID) external view returns (bool);
}