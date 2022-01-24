pragma solidity ^0.4.19;
import "./zombiefactory.sol";

//  Contract to simulate the zombie feeding. This contract inherits from the ZombieFactory contract
contract ZombieFeeding is ZombieFactory {

  /*  Function to feed and multiply the zombie
        _zombieId: zombie ID
        _targetDna: target DNA  
  */
  function feedAndMultiply(uint _zombieId, uint _targetDna) public {
    //  Check if the address that executes the function is the zombie owner
    require(msg.sender == zombieToOwner[_zombieId]);
    //  New struct Zombie variable whose values are equal than the zombie of zombies array with position _zombieId. It's the predator zombie
    Zombie storage myZombie = zombies[_zombieId];
    //  To control that _targetDna have 16 digits it's calculated the modulus. In case is higher than 16 digits, calculating this
    // modulus we get the last 16 digits
    _targetDna = _targetDna % dnaModulus;
    //  The DNA for the new zombie will be the average between the predator zombie and target DNA
    uint newDna = (myZombie.dna + _targetDna) / 2;
    //  With the function in ZombieFactory a new zombie is created. Just for now the new zombie has no name
    _createZombie("NoName", newDna);
  }
  
}
