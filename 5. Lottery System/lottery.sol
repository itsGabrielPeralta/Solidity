// SPDX-License-Identifier: MIT
pragma solidity >0.4.4 <=0.7.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";

contract loteria {

/// ---------------------------------------------------------- INITIAL PARAMETERS --------------------------------------------------

    // Token Contract Instance
    ERC20Basic private token;

    //  Owner Address variable
    address public owner;
    //  Contract address variable
    address public contractAddress;

    //  Initial tokens amount
    uint public initialTokens = 10000;
    //  Token price in ether
    uint public tokenPrice = 1 ether;
    //  Price of a lottery ticket in tokens
    uint public ticketPrice = 5;

    constructor() public {
        //  Define the token parameter
        token = new ERC20Basic(initialTokens);
        //  The owner will be the address deploying the contract
        owner = msg.sender;
        //  Contract address
        contractAddress = address(this);
    }

    //  Mapping with address -> integer number array. The relationship will be between an address buying a ticket and the ticket number
    mapping(address => uint[]) TicketNumber;
    // Relación para identificar al ganador, relacionando el número ganador con la dirección
    //  Mapping with integer number -> address. The relationship will be between the tickets number and the address having this number
    mapping(uint => address) NumberAddress;
    //  Random Number Variable
    uint randNonce = 0;
    //  Array with the created tickets
    uint[] PurchasedTickets;

    // Events
    event Purchased_Tickets(uint, address);
    event Winner_Tickets(uint);

/// ---------------------------------------------------------- MODIFIER & AUX FUNCTIONS ----------------------------------------------

    /*  Modifier that controls that only the owner can execute
        _addressExecuter: address executing 
    */
    modifier OnlyOwner(address _addressExecuter) {
        require(_addressExecuter == owner, "This address don't has permission to execute this function.");
        _;
    }

    /*  Modifier that ensures that the address has enough Ether to bear the cost
        _numTokens: token amount to check
    */
    modifier CheckTokenPurchase(uint _numTokens) {
        require(_numTokens > 0, "The token number must be higher than 0.");
        //  Contract Token Balance
        uint _contractBalance = ContractBalance();
        //  The contract balance must be higher or equal than num tokens requested
        require(_contractBalance >= _numTokens, "The contract don't has enough tokens. The amount must be lower.");
        //  Token Cost Variable
        uint _cost = TokenPrice(_numTokens);
        //  The ehter sent with the function must be higher or equal than cost
        require(msg.value >= _cost, "This address don't has enough Ether to purchased the token amount introduced.");
        _;
    }

    /*  Modifier to check the tickets purchased
        _numTickets: tikect amount to purchased
    */
    modifier CheckTicketPurchase(uint _numTickets) {
        //  Variable with the tickets cost
        uint _ticketPrice = _numTickets * ticketPrice;
        //  Ckeck if address has enough token to bear the tickets purchased
        require(_ticketPrice <= token.balanceOf(msg.sender), "This address don't has enough token to purchased the ticket amount introduced.");
        _;
    }

    /*  Modifier to control the token returns
        _numTokens: token amount to purchased
        _addressExecuter: address to check 
    */
    modifier CheckTokenReturns(uint _numTokens, address _addressExecuter) {
        //  Token amount must be higher than 0
        require(_numTokens > 0, "Token amount must be higher than 0.");
        //  Address must be has enough token to return the amount introduced
        require(_numTokens <= token.balanceOf(_addressExecuter), "This address don't has enough tokens.");
        _;
    }


///  --------------------------------------------------------- TOKEN MANAGEMENT ---------------------------------------------------

    /*  Function to consult the price of token amount
        _numTokens: amount tokens to know the price
    */
    function TokenPrice(uint _numTokens) internal view returns(uint) {
        return _numTokens * tokenPrice;
    }

    /*  Function to generate more tokens
        _numTokens: token amount to create
    */
    function TokenGeneration(uint _numTokens) public OnlyOwner(msg.sender) {
        token.increaseTotalSupply(_numTokens);
    }

    /*  Function to purchased tokens
        _numTokens: token amount to purchased
    */
    function TokenPurchased(uint _numTokens) public payable CheckTokenPurchase(_numTokens) {
        //  Calculate token cost
        uint cost = TokenPrice(_numTokens);
        // Si se envía más ether del que se corresponde con los tokes que se piden se devuelven esos ether. Se crea variable para ello
        //  Check the difference between the ehter value sent with the function and the real cost
        uint returnValue = msg.value - cost;
        //  It there is a difference value will be return to the address
        msg.sender.transfer(returnValue);
        //  The tokens purchased are transfers to the address
        token.transfer(msg.sender, _numTokens);
    }

    //  Function to consult the contrat balance
    function ContractBalance() public view returns(uint) {
        return token.balanceOf(contractAddress);
    }

    //  Function to consult the token pot
    function CheckPot() public view returns (uint) {
        //  The pot will be in the owner address
        return token.balanceOf(owner);
    }

    //  Function to check owned tokens
    function MyTokens() public view returns(uint) {
        return token.balanceOf(msg.sender);
    }

/// ---------------------------------------------------------- LOTTERY MANAGEMENT ---------------------------------------------------

    /*  Function to purchased tickets
        _numTickets: amount of tickets to purchased
    */
    function TicketsPurchase(uint _numTickets) public CheckTicketPurchase(_numTickets) {
        //  It's is calculated the tickets cost
        uint _costTicket = _numTickets * ticketPrice;
        //  Tokens are transfered from client to owner
        token.returnToken(msg.sender, owner, _costTicket);
        //  A random number is generated to assign to the ticket
        for(uint i = 0 ; i < _numTickets ; i++){
            /* Para simular la generación de un método aleatorio se toma la marca de tiempo actual, la dirección del usuario y un nonce para 
                realizar un hash de estos parámetros y se obtiene el módulo al dividir por 10000 para coger lo últimos 4 dígitos del hash dando un valor
                aleatorio entre 0-9999
            */
            uint random = uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % 10000;
            randNonce++; // The value is increased in order to each ticket number is different
            //  The ticket number generated is add to the tickets owned by this address
            TicketNumber[msg.sender].push(random);
            //  The number is associated with this address 
            NumberAddress[random] = msg.sender;
            emit Purchased_Tickets(random, msg.sender);
        }
    }

    //  Function to consult the ticket number of an address 
    function MyTickets() public view returns(uint[] memory) {
        return TicketNumber[msg.sender];
    }

    //  Function to get a winner
    function GetWinner() public OnlyOwner(msg.sender) {
        require(PurchasedTickets.length > 0, "There are not tickets purchased.");
        //  Get the number of tickets 
        uint _length = PurchasedTickets.length;
        //  Get an array position. It's is uint just in case the result is decimal we get the integer part 
        uint _arrayPosition = uint(uint(keccak256(abi.encodePacked(now))) % _length);
        //  Get the winner with array position
        uint _winner = PurchasedTickets[_arrayPosition];
        emit Winner_Tickets(_winner);
        //  Winner Address Variable using the mapping that set the relationship between the number and the address buying it
        address _winnerAddress = NumberAddress[_winner];
        //  Send the tokens to the winner
        token.returnToken(msg.sender, _winnerAddress, CheckPot());
    }

    /*  Function to convert the tokens in ether
        _numTokens: token amount to convert in Ether
    */
    function ConvertTokens2Ether(uint _numTokens) public payable CheckTokenReturns(_numTokens, msg.sender){
        token.returnToken(msg.sender, contractAddress, _numTokens);
        msg.sender.transfer(TokenPrice(_numTokens));
    }
}
