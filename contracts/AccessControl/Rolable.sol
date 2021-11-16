pragma solidity ^0.5.0;

/// Import all Roles
import "./Roles/Consumer.sol";
import "./Roles/Distributor.sol";
import "./Roles/Producer.sol";
import "./Roles/Administrator.sol";
import "./Roles/Retailer.sol";



contract Rolable is Consumer,Producer, Distributor, Administrator, Retailer {

    function whoAmI() public view returns(
        bool consumer,
        bool retailer,
        bool distributor,
        bool producer,
        bool administrator,
    )
    {
        consumer = amIConsumer();
        retailer = amIRetailer();
        distributor = amIDistributor();
        producer = amIProducer();
        administrator = amIAdministratorr();
        designer = amIDesigner();
    }
}
