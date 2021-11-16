pragma solidity ^0.5.0;

import "./Roles.sol";

contract Consumer {


    using Roles for Roles.Role;

    event ConsumerAdded(address indexed account);
    event ConsumerRemoved(address indexed account);

    Roles.Role private _consumers;

    constructor () internal {
        _addConsumer(msg.sender);
    }

    modifier onlyConsumer() {
        require(isConsumer(msg.sender), 'Not A Consumer!');
        _;
    }


    function isConsumer(address account) public view returns (bool) {
        return _consumers.has(account);
    }

    function amIConsumer() public view returns (bool) {
        return _consumers.has(msg.sender);
    }

    function assignMeAsConsumer() public {
        _addConsumer(msg.sender);
    }

    function renounceMeFromConsumer() public {
        _removeConsumer(msg.sender);
    }

    function _addConsumer(address account) internal {
        _consumers.add(account);
        emit ConsumerAdded(account);
    }

    function _removeConsumer(address account) internal {
        _consumers.remove(account);
        emit ConsumerRemoved(account);
    }
}
