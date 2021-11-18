pragma solidity ^0.5.0;

import "../AccessControl/Roles/Administrator.sol";
import "../AccessControl/Roles/Producer.sol";
import "../AccessControl/Roles/Consumer.sol";
import "../AccessControl/Roles/Retailer.sol";
import "../AccessControl/Roles/Distributor.sol";
import "../Core/Ownable.sol";

contract SupplyChain is Ownable, Administrator,Distributor,Retailer,Consumer, Producer {
  address owner;
  uint upc; //universal Product Code
  uint sku //stock keeping unit

  mapping (uint => Item) items;

  mapping (uint =>Txblocks) itemsHistory;

  enum State
  {
    ProducedByProducer,         // 0
    ForSaleByProducer,         // 1
    PurchasedByDistributor,  // 2
    ShippedByProducer,         // 3
    ReceivedByDistributor,   // 4
    ProcessedByDistributor,  // 5
    PackageByDistributor,    // 6
    ForSaleByDistributor,    // 7
    PurchasedByRetailer,     // 8
    ShippedByDistributor,    // 9
    ReceivedByRetailer,      // 10
    ForSaleByRetailer,       // 11
    PurchasedByConsumer      // 12
    }
    enum ProductIdentity{
      Egg,
      Milk,
      Vegetables;
    }

  //ProductIdentity constant defaultState= ProductIdentity.Egg;
  State constant defaultState = State.ProduceByProducer;

  // Define a struct 'Item' with the following fields:
  struct Item {
    uint    sku;                    // Stock Keeping Unit (SKU)
    uint    upc;                    // Universal Product Code (UPC), generated by the Producer, goes on the package, can be verified by the Consumer
    address ownerID;                // Metamask-Ethereum address of the current owner as the product moves through 8 stages
    address originProducerID;         // Metamask-Ethereum address of the Producer // ADDED PAYABLE
    string  originProducerName;         // Producer Name
    string  originFarmInformation;  // Producer Information
    string  originFarmLatitude;     // Farm Latitude
    string  originvFarmLongitude;    // Farm Longitude
    uint    productID;              // Product ID potentially a combination of upc + sku
    string  productNotes;           // Product Notes
    uint256 productDate;            // Product Date NOTE: MIGHT NEED TO CHANGE type
    uint    productPrice;           // Product Price
    //uint    productSliced;
    uint    bestBefore;             // Expiry Time
    ProductIdentity productType;    //Product Type {egg,milk,vegetables}
    State   itemState;              // Product State as represented in the enum above
    address distributorID;          // Metamask-Ethereum address of the Distributor
    address retailerID;             // Metamask-Ethereum address of the Retailer
    address consumerID;             // Metamask-Ethereum address of the Consumer // ADDED payable
  }

// Block number stuct
  struct Txblocks {
    uint FTD; // blockProducerToDistributor
    uint DTR; // blockDistributorToRetailer
    uint RTC; // blockRetailerToConsumer
  }


event ProduceByProducer(uint upc);         //1
event ForSaleByProducer(uint upc);         //2
event PurchasedByDistributor(uint upc);  //3
event ShippedByProducer(uint upc);         //4
event ReceivedByDistributor(uint upc);   //5
event ProcessedByDistributor(uint upc);  //6
event PackagedByDistributor(uint upc);   //7
event ForSaleByDistributor(uint upc);    //8
event PurchasedByRetailer(uint upc);     //9
event ShippedByDistributor(uint upc);    //10
event ReceivedByRetailer(uint upc);      //11
event ForSaleByRetailer(uint upc);       //12
event PurchasedByConsumer(uint upc);     //13

modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  // Define a modifer that verifies the Caller
  modifier verifyCaller (address _address) {
    require(msg.sender == _address);
    _;
  }

  // Define a modifier that checks if the paid amount is sufficient to cover the price
  modifier paidEnough(uint _price) {
    require(msg.value >= _price);
    _;
  }

  modifier checkValue(uint _upc, address payable addressToFund) {
    uint _price = items[_upc].productPrice;
    uint  amountToReturn = msg.value - _price;
    addressToFund.transfer(amountToReturn);
    _;
  }

//Item State Modifiers
  modifier producedByProducer(uint _upc) {
    require(items[_upc].itemState == State.ProduceByProducer);
    _;
  }

  modifier forSaleByProducer(uint _upc) {
    require(items[_upc].itemState == State.ForSaleByProducer);
    _;
  }

  modifier purchasedByDistributor(uint _upc) {
    require(items[_upc].itemState == State.PurchasedByDistributor);
    _;
  }

  modifier shippedByProducer(uint _upc) {
    require(items[_upc].itemState == State.ShippedByProducer);
    _;
  }

  modifier receivedByDistributor(uint _upc) {
    require(items[_upc].itemState == State.ReceivedByDistributor);
    _;
  }

  modifier processByDistributor(uint _upc) {
    require(items[_upc].itemState == State.ProcessedByDistributor);
    _;
  }

  modifier packagedByDistributor(uint _upc) {
    require(items[_upc].itemState == State.PackageByDistributor);
    _;
  }

  modifier forSaleByDistributor(uint _upc) {
    require(items[_upc].itemState == State.ForSaleByDistributor);
    _;
  }


  modifier shippedByDistributor(uint _upc) {
    require(items[_upc].itemState == State.ShippedByDistributor);
    _;
  }

  modifier purchasedByRetailer(uint _upc) {
    require(items[_upc].itemState == State.PurchasedByRetailer);
    _;
  }

  modifier receivedByRetailer(uint _upc) {
    require(items[_upc].itemState == State.ReceivedByRetailer);
    _;
  }

  modifier forSaleByRetailer(uint _upc) {
    require(items[_upc].itemState == State.ForSaleByRetailer);
    _;
  }

  modifier purchasedByConsumer(uint _upc) {
    require(items[_upc].itemState == State.PurchasedByConsumer);
    _;
  }
  modifier checkProduct(string _prodType){
    require((_prodType==ProductIdentity.Egg)||(_prodType==ProductIdentity.Milk)||(_prodType==ProductIdentity.Vegetables),'NOT A SPECIFIED PRODUCT');
    _;
  }
// constructor setup owner sku upc
  constructor() public payable {
    owner = msg.sender;
    sku = 1;
    upc = 1;
  }

    // Define a function 'kill'
  function kill() public {
    if (msg.sender == owner) {
      address payable ownerAddressPayable = _make_payable(owner);
      selfdestruct(ownerAddressPayable);
    }
  }


    // allows you to convert an address into a payable address
  function _make_payable(address x) internal pure returns (address payable) {
      return address(uint160(x));
  }


  function produceItemByProducer(uint _upc, string memory prodtype, string memory _originFarmName, string memory _originFarmInformation, string memory _originFarmLatitude, string memory _originFarmLongitude, string memory _productNotes, uint _price) public
    onlyProducer() // check address belongs to ProducerRole
    checkProduct(prodtype)
    {

    address distributorID; // Empty distributorID address
    address retailerID; // Empty retailerID address
    address consumerID; // Empty consumerID address
    Item memory newProduce; // Create a new struct Item in memory
    newProduce.sku = sku;  // Stock Keeping Unit (SKU)
    newProduce.upc = _upc; // Universal Product Code (UPC), generated by the Producer, goes on the package, can be verified by the Consumer
    newProduce.ownerID = msg.sender;  // Metamask-Ethereum address of the current owner as the product moves through 8 stages
    newProduce.originProducerID = msg.sender; // Metamask-Ethereum address of the Producer
    newProduce.originFarmName = _originFarmName;  // Producer Name
    newProduce.originFarmInformation = _originFarmInformation; // Producer Information
    newProduce.originFarmLatitude = _originFarmLatitude; // Farm Latitude
    newProduce.originFarmLongitude = _originFarmLongitude;  // Farm Longitude
    newProduce.productID = _upc+sku;  // Product ID
    newProduce.productNotes = _productNotes; // Product Notes
    newProduce.productPrice = _price;  // Product Price
    newProduce.productDate = now;
    newProduce.ProductIdentity=ProductIdentity.prodtype;
    newProduce.productSliced = 0;
    newProduce.itemState = defaultState; // Product State as represented in the enum above
    newProduce.distributorID = distributorID; // Metamask-Ethereum address of the Distributor
    newProduce.retailerID = retailerID; // Metamask-Ethereum address of the Retailer
    newProduce.consumerID = consumerID; // Metamask-Ethereum address of the Consumer // ADDED payable
    items[_upc] = newProduce; // Add newProduce to items struct by upc
    uint placeholder; // Block number place holder
    Txblocks memory txBlock; // create new txBlock struct
    txBlock.FTD = placeholder; // assign placeholder values
    txBlock.DTR = placeholder;
    txBlock.RTC = placeholder;
    itemsHistory[_upc] = txBlock; // add txBlock to itemsHistory mapping by upc

    // Increment sku
    sku = sku + 1;

    // Emit the appropriate event
    emit ProduceByProducer(_upc);

  }

  /*
  2nd step in supplychain
  Allows Producer to sell cheese
  */
  function sellItemByProducer(uint _upc, uint _price) public
    onlyProducer() // check msg.sender belongs to ProducerRole
    producedByProducer(_upc) // check items state has been produced
    verifyCaller(items[_upc].ownerID) // check msg.sender is owner
    {
      items[_upc].itemState = State.ForSaleByProducer;
      items[_upc].productPrice = _price;
      emit ForSaleByProducer(_upc);
  }

  /*
  3rd step in supplychain
  Allows distributor to purchase cheese
  */
  function purchaseItemByDistributor(uint _upc) public payable
    onlyDistributor() // check msg.sender belongs to distributorRole
    forSaleByProducer(_upc) // check items state is for ForSaleByProducer
    paidEnough(items[_upc].productPrice) // check if distributor sent enough Ether for cheese
    checkValue(_upc, msg.sender) // check if overpayed return remaing funds back to msg.sender
    {
    address payable ownerAddressPayable = _make_payable(items[_upc].originProducerID); // make originFarmID payable
    ownerAddressPayable.transfer(items[_upc].productPrice); // transfer funds from distributor to Producer
    items[_upc].ownerID = msg.sender; // update owner
    items[_upc].distributorID = msg.sender; // update distributor
    items[_upc].itemState = State.PurchasedByDistributor; // update state
    itemsHistory[_upc].FTD = block.number; // add block number
    emit PurchasedByDistributor(_upc);

  }

  /*
  4th step in supplychain
  Allows Producer to ship cheese purchased by distributor
  */
  function shippedItemByProducer(uint _upc) public payable
    onlyProducer() // check msg.sender belongs to ProducerRole
    purchasedByDistributor(_upc)
    verifyCaller(items[_upc].originProducerID) // check msg.sender is originFarmID
    {
    items[_upc].itemState = State.ShippedByProducer; // update state
    emit ShippedByProducer(_upc);
  }

  /*
  5th step in supplychain
  Allows distributor to receive cheese
  */
  function receivedItemByDistributor(uint _upc) public
    onlyDistributor() // check msg.sender belongs to DistributorRole
    shippedByProducer(_upc)
    verifyCaller(items[_upc].ownerID) // check msg.sender is owner
    {
    items[_upc].itemState = State.ReceivedByDistributor; // update state
    emit ReceivedByDistributor(_upc);
  }

  /*
  6th step in supplychain
  Allows distributor to process cheese
  */
  function processedItemByDistributor(uint _upc,uint slices) public
    onlyDistributor() // check msg.sender belongs to DistributorRole
    receivedByDistributor(_upc)
    verifyCaller(items[_upc].ownerID) // check msg.sender is owner
    {
    items[_upc].itemState = State.ProcessedByDistributor; // update state
    items[_upc].productSliced = slices; // add slice amount
    emit ProcessedByDistributor(_upc);
  }

  /*
  7th step in supplychain
  Allows distributor to package cheese
  */
  function packageItemByDistributor(uint _upc) public
    onlyDistributor() // check msg.sender belongs to DistributorRole
    processByDistributor(_upc)
    verifyCaller(items[_upc].ownerID) // check msg.sender is owner
    {
    items[_upc].itemState = State.PackageByDistributor;
    emit PackagedByDistributor(_upc);
  }

  /*
  8th step in supplychain
  Allows distributor to sell cheese
  */
  function sellItemByDistributor(uint _upc, uint _price) public
    onlyDistributor() // check msg.sender belongs to DistributorRole
    packagedByDistributor(_upc)
    verifyCaller(items[_upc].ownerID) // check msg.sender is owner
    {
        items[_upc].itemState = State.ForSaleByDistributor;
        items[_upc].productPrice = _price;
        emit ForSaleByDistributor(upc);
  }

  /*
  9th step in supplychain
  Allows retailer to purchase cheese
  */
  function purchaseItemByRetailer(uint _upc) public payable
    onlyRetailer() // check msg.sender belongs to RetailerRole
    forSaleByDistributor(_upc)
    paidEnough(items[_upc].productPrice)
    checkValue(_upc, msg.sender)
    {
    address payable ownerAddressPayable = _make_payable(items[_upc].distributorID);
    ownerAddressPayable.transfer(items[_upc].productPrice);
    items[_upc].ownerID = msg.sender;
    items[_upc].retailerID = msg.sender;
    items[_upc].itemState = State.PurchasedByRetailer;
    itemsHistory[_upc].DTR = block.number;
    emit PurchasedByRetailer(_upc);
  }

  /*
  10th step in supplychain
  Allows Distributor to
  */
  function shippedItemByDistributor(uint _upc) public
    onlyDistributor() // check msg.sender belongs to DistributorRole
    purchasedByRetailer(_upc)
    verifyCaller(items[_upc].distributorID) // check msg.sender is distributorID
    {
      items[_upc].itemState = State.ShippedByDistributor;
      emit ShippedByDistributor(_upc);
  }

  /*
  11th step in supplychain
  */
  function receivedItemByRetailer(uint _upc) public
    onlyRetailer() // check msg.sender belongs to RetailerRole
    shippedByDistributor(_upc)
    verifyCaller(items[_upc].ownerID) // check msg.sender is ownerID
    {
      items[_upc].itemState = State.ReceivedByRetailer;
      emit ReceivedByRetailer(_upc);
  }

  /*
  12th step in supplychain
  */
  function sellItemByRetailer(uint _upc, uint _price) public
    onlyRetailer()  // check msg.sender belongs to RetailerRole
    receivedByRetailer(_upc)
    verifyCaller(items[_upc].ownerID) // check msg.sender is ownerID
    {
      items[_upc].itemState = State.ForSaleByRetailer;
      items[_upc].productPrice = _price;
      emit ForSaleByRetailer(_upc);
  }

  /*
  13th step in supplychain
  */
  function purchaseItemByConsumer(uint _upc) public payable
    onlyConsumer()  // check msg.sender belongs to ConsumerRole
    forSaleByRetailer(_upc)
    paidEnough(items[_upc].productPrice)
    checkValue(_upc, msg.sender)
    {
      items[_upc].consumerID = msg.sender;
      address payable ownerAddressPayable = _make_payable(items[_upc].retailerID);
      ownerAddressPayable.transfer(items[_upc].productPrice);
      items[_upc].ownerID = msg.sender;
      items[_upc].consumerID = msg.sender;
      items[_upc].itemState = State.PurchasedByConsumer;
      itemsHistory[_upc].RTC = block.number;
    emit PurchasedByConsumer(_upc);
  }

  // Define a function 'fetchItemBufferOne' that fetches the data
  function fetchItemBufferOne(uint _upc) public view returns
    (
    uint    itemSKU,
    uint    itemUPC,
    address ownerID,
    address originProducerID,
    string memory  originFarmName,
    string memory originFarmInformation,
    string memory originFarmLatitude,
    string memory originFarmLongitude,
    uint productDate,
    //uint productSliced
    )
    {
    // Assign values to the 8 parameters
    Item memory item = items[_upc];

    return
    (
      item.sku,
      item.upc,
      item.ownerID,
      item.originProducerID,
      item.originFarmName,
      item.originFarmInformation,
      item.originFarmLatitude,
      item.originFarmLongitude,
      item.productDate,
      //item.productSliced
    );
  }

  // Define a function 'fetchItemBufferTwo' that fetches the data
  function fetchItemBufferTwo(uint _upc) public view returns
    (
    uint    itemSKU,
    uint    itemUPC,
    uint    productID,
    string  memory productNotes,
    uint    productPrice,
    uint256 productDate,
    State   itemState,
    ProductIdentity productType,
    address distributorID,
    address retailerID,
    address consumerID
    )
    {
      // Assign values to the 9 parameters
    Item memory item = items[_upc];

    return
    (
      item.sku,
      item.upc,
      item.productType,
      item.productID,
      item.productNotes,
      item.productPrice,
      item.productDate,
      item.itemState,
      item.distributorID,
      item.retailerID,
      item.consumerID
    );

  }

  // Define a function 'fetchItemHistory' that fetaches the data
  function fetchitemHistory(uint _upc) public view returns
    (
      uint blockProducerToDistributor,
      uint blockDistributorToRetailer,
      uint blockRetailerToConsumer
    )
    {
      // Assign value to the parameters
      Txblocks memory txblock = itemsHistory[_upc];
      return
      (
        txblock.FTD,
        txblock.DTR,
        txblock.RTC
      );

    }

  }



}