// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 < 0.7.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";

contract leisure_park {

/// --------------------------------------------------------------------- INITIAL PARAMETERS -----------------------------------------------
    //  Token Contract Instance Variable
    ERC20Basic private token;

    //  Owner Address Variable. It must be payable because this address will have ethers transfer
    address payable public owner;

    // Constructor
    constructor() public {
        // Token initial supply of the contract
        token = new ERC20Basic(10000);
        // Address who execute the contract is assigned to the owner variable
        owner = msg.sender;
    }

    // Client struct with the data needed
    struct client {
        uint tokens;
        string[] rideEnjoyed;
    }

    // Ride struct with the data needed
    struct ride {
        string rideName;
        uint ridePrice;
        bool rideState; // true is available and false not
    }

    //  Mapping with address to client struct. This mapping define the relationship between an address and a client
    mapping(address => client) public Clients;
    // Mapping with string to ride struct. This mapping define the relationship between the ride name and a ride
    mapping (string => ride) public Rides;
    // Mapping with an address to string array. This mapping define the relationship between an address and the array where will be storage the ride history
    mapping(address => string[]) RideHistory;

    // String array to storage the ride's name
    string[] RidesName;

    // Events
    event Ride_Enjoyed(string);
    event New_Ride(string, uint);
    event Disable_Ride(string);

///  ------------------------------------------------------------------- MODIFIER & AUX FUNCTIONS -------------------------------------------------------

    /*  Modifier to control that the function is executed only by the owner of the contract
        _addressExecuter: address who execute the function
    */
    modifier OnlyOwner(address _addressExecuter) {
        require(_addressExecuter == owner, "This address don't have permissions to execute this function.");
        _;
    }

    /*  Modifier to check if a ride is available
        _name: ride name
    */
    modifier RideAvailable(string memory _name) {
        require(Rides[_name].rideState == true, "This ride is disabled rigth now.");
        _;
    }


///  ------------------------------------------------------------------- TOKEN MANAGEMENT -------------------------------------------------------

    /*  Function to define the token price
        _numTokens: number of tokens to know their price in ether
    */
    function TokenPrice(uint _numTokens) internal pure returns (uint) {
        //  1 Token -> 1 Ether
        return _numTokens*(1 ether);
    }

    /*  Function to buy tokens 
        _numTokens: number of tokens to buy
    */
    function TokenBuy(uint _numTokens) public payable {
        // Get the cost in ether 
        uint cost = TokenPrice(_numTokens);
        //  It is checked that the address have enough ether
        require(msg.value >= cost, "This address don't have enough tokens.");
        // It is checked if there is a difference between the ether sent and the cost
        uint returnValue = msg.value - cost;
        // Contract returns the difference value
        msg.sender.transfer(returnValue);
        //  Get the contract token balance
        uint balance = ContractBalance();
        //  It is checked that the contract have enough token to send to the buyer
        require(_numTokens <= balance, "The contract don't have enough token. You have to buy a lower amount.");
        //  The token is sent from the contract to the buyer's address with a ERC20.sol method
        token.transfer(msg.sender, _numTokens);
        //  The tokens is added to the client
        Clients[msg.sender].tokens += _numTokens;
    }

    //  Function to query the contract token supply in this moment
    function ContractBalance() public view returns(uint) {
        return token.balanceOf(address(this));
    }

    //  Function to query the amount of tokens of the executing address
    function MyTokens() public view returns(uint) {
        return token.balanceOf(msg.sender);
    }

    /*  Function to create more tokens
        _numTokens: amount of token to create
    */
    function GenerateTokens(uint _numTokens) public OnlyOwner(msg.sender) {
        token.increaseTotalSupply(_numTokens);
    }

///  -------------------------------------------------------------------------- LEISURE PARK MANAGEMENT -----------------------------------------------------

    /*  Function to add new ride
        _name: ride name 
        _price: ride price
    */
    function NewRide(string memory _name, uint _price) public OnlyOwner(msg.sender) {
        //  Add new ride using the mapping that set the relationship between the ride name and the ride struct
        Rides[_name] = ride(_name, _price, true);
        // Storage in the ride name array
        RidesName.push(_name);
        // Emit event that indicate new ride
        emit New_Ride(_name, _price);
    }

    /*  Function to set disabled a ride
        _name: ride name
    */
    function DisableRide(string memory _name) public OnlyOwner(msg.sender) {
        // El estado de la atracción pasa a false
        Rides[_name].rideState = false;
        // Emit the event
        emit Disable_Ride(_name);
    }

    //  Function to see the rides in the park 
    function ParkRides() public view returns(string[] memory) {
        return RidesName;
    }

    /*  Function to pay a ride
        _name: ride name
    */
    function PayRide(string memory _name) public RideAvailable(_name) {
        //  Get the ride price in token
        uint _rideTokenCost = Rides[_name].ridePrice;
        //  Check if address executer have enough tokens
        require(_rideTokenCost <= MyTokens(), "This address don't have enough token to pay this ride.");
        //  Use a ERC20.sol method to return the tokens from de client to the contract
        token.returnToken(msg.sender, address(this), _rideTokenCost);
        //  Add the ride in client history
        RideHistory[msg.sender].push(_name);
        // Emit the event
        emit Ride_Enjoyed(_name);

    }

    //  Query the ride history of address who execute this function
    function QueryRideHistory() public view returns(string[] memory) {
        return RideHistory[msg.sender];
    }

    /*  Function to client can return token and recieve ether
        _numTokens: amount of tokens to returns
    */
    function ReturnTokens(uint _numTokens) public payable {
        //  Check if the number of tokens is higher than 0
        require(_numTokens > 0, "You have to add a token amount higher than 0.");
        //  Check if the cliente have enough token
        require(_numTokens <= MyTokens(), "This address don't have enough tokens.");
        //  The client returns tokens
        token.returnToken(msg.sender, address(this), _numTokens);
        // The contract transfer the token value in ether
        msg.sender.transfer(TokenPrice(_numTokens));
    }
}
