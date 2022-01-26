pragma solidity ^0.4.19;
import "./zombieattack.sol";
import "./erc721.sol";

contract ZombieOwnership is ZombieAttack, ERC721 {

    //  Mapping to storage who is authorized to receipt a token
    mapping (uint => address) zombieApprovals;

    /*  Function to consult an address balance
        _owner: address to consult
    */
    function balanceOf(address _owner) public view returns (uint256 _balance) {
        _balance = ownerZombieCount[_owner];
    }

    /*  Function to return the owner address who owned the zombie
        _tokenId: zombie ID
    */
    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        _owner = zombieToOwner[_tokenId];
    }

    /*  Function to transfer
        _from: sender address
        _to: receipt address
        _tokenId: token to send
    */
    function _transfer(address _from, address _to, uint256 _tokenId) private {
        //  Increase the zombie count owned by receipt address using SafeMath library
        ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
        //  Decrease the zombie count owned by sender address using SafeMath library
        ownerZombieCount[_from] = ownerZombieCount[_from].sub(1);
        //  The mapping defined that pinting to _from address how the token owner now is changed as _to address as new owner
        zombieToOwner[_tokenId] = _to;
        //  Emit event Transfer
        emit Transfer(_from, _to, _tokenId);
    }

    /*  Function to call the private function _transfer to send the token from the address who execute the function to another address
        _to: receipt address
        _tokenId: token ID to send
    */
    function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        _transfer(msg.sender, _to, _tokenId);
    }

    /*  Function to the owner of a token authorized a different address to receipt the the token
        _to: address who will be authoraized
        _tokenId: token ID to transfer
    */
    function approve(address _to, uint256 _tokenId) public onlyOwnerOf()_tokenId {
        //  Set the address aprove in the mapping
        zombieApprovals[_tokenId] = _to;
        //  Emit the approval event
        Approval(msg.sender, _to, _tokenId);
    }

    /*  Function to take a token by an authorized address
        _tokenId: token ID to take
    */
    function takeOwnership(uint256 _tokenId) public {
        //  Check if the executer address is authorized to take the indicated token
        require(zombieApprovals[_tokenId] == msg.sender);
        //  Get the address who owned the token rigth now
        address owner = ownerOf(_tokenId);
        //  Take the token by _transfer function indicating the parameters on the rigth way
        _transfer(owner, msg.sender, _tokenId);
    }

}
