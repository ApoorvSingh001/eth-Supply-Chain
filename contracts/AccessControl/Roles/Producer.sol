pragma solidity ^0.5.0;


import "./Roles.sol"


contract Producer {

    using Roles for Roles.Role;

    event ProducerAdded(address indexed account);
    event ProducerRemoved(address indexed account);

    Roles.Role private _producers;

    constructor () internal {
        _addProducer(msg.sender);
    }

    modifier onlyProducer() {
        require(isProducer(msg.sender), 'Not A Producer!');
        _;
    }


    function isProducer(address account) public view returns (bool) {
        return _producers.has(account);
    }

    function amIProducer() public view returns (bool) {
        return _producers.has(msg.sender);
    }

    function assignMeAsProducer() public {
        _addProducer(msg.sender);
    }

    function renounceMeFromProducer() public {
        _removeProducer(msg.sender);
    }


    function _addProducer(address account) internal {
        _producers.add(account);
        emit ProducerAdded(account);
    }

    function _removeProducer(address account) internal {
        _producers.remove(account);
        emit ProducerRemoved(account);
    }
}
