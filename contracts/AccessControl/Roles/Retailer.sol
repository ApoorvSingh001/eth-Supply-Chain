pragma solidity ^0.5.0;

import "./Roles.sol"

contract Retailer {

    using Roles for Roles.Role;

    event RetailerAdded(address indexed account);
    event RetailerRemoved(address indexed account);

    Roles.Role private _retailers;

    constructor () internal {
        _addRetailer(msg.sender);
    }

    modifier onlyRetailer() {
        require(isRetailer(msg.sender), 'Not A Retailer!');
        _;
    }

    function isRetailer(address account) public view returns (bool) {
        return _retailers.has(account);
    }

    function amIRetailer() public view returns (bool) {
        return _retailers.has(msg.sender);
    }

    function assignMeAsRetailer() public {
        _addRetailer(msg.sender);
    }

    function renounceMeFromRetailer() public {
        _removeRetailer(msg.sender);
    }

    function _addRetailer(address account) internal {
        _retailers.add(account);
        emit RetailerAdded(account);
    }

    function _removeRetailer(address account) internal {
        _retailers.remove(account);
        emit RetailerRemoved(account);
    }
}
