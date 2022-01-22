// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 < 0.7.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";


//  Token ERC20 Interface
interface IERC20{

    //  Returns the total amount of token that the contract has
    function totalSupply() external view returns (uint256);

    /*  Returns the amount of token that an address has
        account: address whose amount of token want to know
    */  
    function balanceOf(address account) external view returns (uint256);

    /*  Returns the amount of token that an address can use with the permission of the original owner of the token
        owner: token's owner
        spender: address that wants to use the tokens
    */
    function allowance(address owner, address spender) external view returns (uint256);

    /*  Function to transfer from the address who executes the function to another address
        recipient: address that receives the tokens
        amount: token amount to transfer
    */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /*  Function to transfer from an address to another
        spender: address who transfer
        recipient: address who receive
        amount: token amount to transfer
    */
    function returnToken(address spender, address recipient, uint256 amount) external returns (bool);

    /*  Function to give permission an address over a token amount
        spender: address who want to have permission over the tokens 
        amount: token amount over spender will have permissions
    */
    function approve(address spender, uint256 amount) external returns (bool);

    /*  Function to send token from the owner to a buyer address
        owner: token's owner
        buyer: address who buy the tokens
        amount: token amount to buy
    */
    function transferFrom(address owner, address buyer, uint256 amount) external returns (bool);



    //  Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


//  In the interface the functions were started and in the contract their funcionality is implemented
contract ERC20Basic is IERC20{

    string public constant name = "ERC20BlockchainAZ";
    string public constant symbol = "ERC";
    uint8 public constant decimals = 18;

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed owner, address indexed spender, uint256 tokens);


    using SafeMath for uint256;

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
    uint256 totalSupply_;

    constructor (uint256 initialSupply) public{
        totalSupply_ = initialSupply;
        balances[msg.sender] = totalSupply_;
    }


    function totalSupply() public override view returns (uint256){
        return totalSupply_;
    }

    function increaseTotalSupply(uint newTokensAmount) public {
        totalSupply_ += newTokensAmount;
        balances[msg.sender] += newTokensAmount;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256){
        return balances[tokenOwner];
    }

    function allowance(address owner, address delegate) public override view returns (uint256){
        return allowed[owner][delegate];
    }

    function transfer(address recipient, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[recipient] = balances[recipient].add(numTokens);
        emit Transfer(msg.sender, recipient, numTokens);
        return true;
    }

    function returnToken(address _cliente, address _receiver, uint256 _numTokens) public override returns (bool){
        require(_numTokens <= balances[_cliente]);
        balances[_cliente] = balances[_cliente].sub(_numTokens);
        balances[_receiver] = balances[_receiver].add(_numTokens);
        emit Transfer(_cliente, _receiver, _numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool){
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}
