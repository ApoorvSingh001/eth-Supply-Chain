pragma solidity ^0.5.0;


import "./Roles.sol"


contract Administrator {

    using Roles for Roles.Role;

    event AdministratorAdded(address indexed account);
    event AdministratorRemoved(address indexed account);

    Roles.Role private _administrators;

    /// @notice constructer will assign the deployer as 1st administrator
    constructor () internal {
        _addAdministrator(msg.sender);
    }

    modifier onlyAdministrator() {
        require(isAdministrator(msg.sender), 'Not A Administrator!');
        _;
    }

    function isAdministrator(address account) public view returns (bool) {
        return _administrators.has(account);
    }
    function amIAdministrator() public view returns (bool) {
        return _administrators.has(msg.sender);
    }

    function addAdministrator(address account) public onlyAdministrator() {
        _addAdministrator(account);
    }

    function renounceMeFromAdministrator() public {
        _removeAdministrator(msg.sender);
    }

    function _addAdministrator(address account) internal {
        _administrators.add(account);
        emit AdministratorAdded(account);
    }

    function _removeAdministrator(address account) internal {
        _administrators.remove(account);
        emit AdministratorRemoved(account);
    }
}
