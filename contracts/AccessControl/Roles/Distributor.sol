pragma solidity ^0.5.0;

import "./Roles.sol";

contract Distributor {

    using Roles for Roles.Role;

    event DistributorAdded(address indexed account);
    event DistributorRemoved(address indexed account);

    Roles.Role private _distributors;

    constructor () internal {
        _addDistributor(msg.sender);
    }

    modifier onlyDistributor() {
        require(isDistributor(msg.sender), 'Not A Distributor!');
        _;
    }

    function isDistributor(address account) public view returns (bool) {
        return _distributors.has(account);
    }

    function amIDistributor() public view returns (bool) {
        return _distributors.has(msg.sender);
    }

    function assignMeAsDistributor() public {
        _addDistributor(msg.sender);
    }

    function renounceMeFromDistributor() public {
        _removeDistributor(msg.sender);
    }


    function _addDistributor(address account) internal {
        _distributors.add(account);
        emit DistributorAdded(account);
    }

    function _removeDistributor(address account) internal {
        _distributors.remove(account);
        emit DistributorRemoved(account);
    }
}
