pragma solidity ^0.4.19;
import "./zombiefactory.sol";

//  Zombies eat CryptoKitties that is a project in Ethereum network. To use a function of CryptoKitties we set the next interface
contract KittyInterface {
  //  We have interest on the getKitty function inside the CryptoKitties project so it's defined below
  function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}


//  Contract to simulate the zombie feeding. This contract inherits from the ZombieFactory contract
contract ZombieFeeding is ZombieFactory {

  //  To use function in KittyInterface is necessary define a instance of her contract using its address
  //  CryptoKitties Contract Address Variable
  address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
  //  Define the interface instance
  KittyInterface kittyContract = KittyInterface(ckAddress);

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
  
  /*  Function to get the kitty genes using the CryptoKitty interface and simulate the zombie feeding
      _zombieId: zombie ID
      _kittyId: kitty ID
  */
  function feedOnKitty(uint _zombieId, uint _kittyId) public {
    //  Kitty DNA Variable
    uint kittyDna;
    //  Using getKitty function to get the kitty DNA using his ID. Only has interest for this case the genes value returns
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
    //  Using feedAndMultiply function that is in this contract to simulate the zombie feeding
    feedAndMultiply(_zombieId, kittyDna);
  }  
  
}
