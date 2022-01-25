pragma solidity ^0.4.19;
import "./zombiefeeding.sol";

contract ZombieHelper is ZombieFeeding {

    /*  Modifier to restrict funcionalities base on zombie level
        _level: level require
        _zombieId: zombie ID
    */
    modifier aboveLevel(uint _level, uint _zombieId) {
        require(zombies[_zombieId].level >= _level);
        _;
    }

    /*  Function to change a zombie name. Only can change the name if zombie has level equal or higher than 2
        _zombieID: zombie ID to change the name
        _newName: zombie new name
    */
    function changeName(uint _zombieId, string _newName) external aboveLevel(2, _zombieId){
        //  Only the zombie owner can change the name
        require(msg.sender == zombieToOwner[_zombieId]);
        //  Set the new name
        zombies[_zombieId].name = _newName;
    }

    /*  Function to change a zombie DNA. It's necessary that the level zombie are equal or higher than 20
        _zombieId: zombie ID to change the DNA
        _newDna: zombie new DNA
    */
    function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId){
        //  Only the zombie owner can change the DNA
        require(msg.sender == zombieToOwner[_zombieId]);
        //  Set the new DNA
        zombies[_zombieId].dna = _newDna;
    }

    /*  Function to show all zombies owned by an address
        _owner: zombies owner address that wants to consult
    */
    function getZombiesByOwner(address _owner) external view returns(uint []){
        //  The array length will be the count of zombies owned by the address sent with the function
        uint[] memory result = new uint[](ownerZombieCount[_owner]);
        //  Count variable to control the arra index
        uint counter = 0;
        //  For bucle to see each zombie in the zombies array
        for(uint i = 0 ; i < zombies.length ; i++){
            //  If the zombie owner is equal than the owner sent with the function the zombie ID is storage in result array
            if(zombieToOwner[i] == _owner){
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

}