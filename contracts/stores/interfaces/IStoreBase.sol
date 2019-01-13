pragma solidity ^0.4.24;

contract IStoreBase {

    event NewConverter(address _converterAddress, address indexed _creator);

    function name() public view returns(bytes32) {}
    function formula() public view returns(address) {}
    function tkzconverter() public view returns(address) {}
    function productsList(uint _index) public view returns(bytes32) {}

    function getProduct(bytes32 _appId) public view returns(address, address, uint256, uint256, bytes32 ,uint256);
    function productsCount() public view returns (uint);
    function addStake(bytes32 _appId) public payable;
    function updateDiscountFactor(uint _percentage, bytes32 _appId) public;

    // TESTING ONLY
    function changeWeight(uint32 _percentage) public;
    function changeMaxStake(uint _val) public;
    function changeMinStake(uint _val) public;
    function removeProduct(bytes32 _appId) public;
    // TESTING ONLY

}
