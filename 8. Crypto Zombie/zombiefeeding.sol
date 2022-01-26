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
    //  Define the interface instance
    KittyInterface kittyContract;

    /*  Modifier to control that the zombie owner is who execute the function to do some action with zombie
        _zombieId: zombie ID
    */
    modifier ownerOf(uint _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);
        _;
    }

    /*  Function to introduce/change the CryptoKitty Contract Address just in case the project changed the contract address for some reason
        _address: CryptoKitty contract address
    */
    function setKittyContractAddress(address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }

    /*  Function to set the cooldown period of a zombie
        _zombie: zombie struct
    */
    function _triggerCooldown(Zombie storage _zombie) internal {
        _zombie.readyTime = uint32(now + cooldownTime);
    }

    /*  Function to check if a zombie is ready
        _zombie: zombie struct
    */
    function _isReady(Zombie storage _zombie) internal view returns(bool) {
        // return true if zombie is ready
        return (_zombie.readyTime <= now);
    }

    /*  Function to feed and multiply the zombie
        _zombieId: zombie ID
        _targetDna: target DNA
        _species: to identify if zombie generation  comes from eat a kitty 
    */
    function feedAndMultiply(uint _zombieId, uint _targetDna, string _species) internal ownerOf(_zombieId){
        //  New struct Zombie variable whose values are equal than the zombie of zombies array with position _zombieId. It's the predator zombie
        Zombie storage myZombie = zombies[_zombieId];
        //  In order to continue the function the zombie must be ready
        require(_isReady(myZombie));
        //  To control that _targetDna have 16 digits it's calculated the modulus. In case is higher than 16 digits, calculating this
        // modulus we get the last 16 digits
        _targetDna = _targetDna % dnaModulus;
        //  The DNA for the new zombie will be the average between the predator zombie and target DNA
        uint newDna = (myZombie.dna + _targetDna) / 2;
        //  For zombies generation that comes to eat a kitty will have the DNA last two digits equals all of them
        if(keccak256(_species) == keccak256("kitty")){
            //  Delet the two last digits and add 99 into newDna variable
            //  Example: newDna = 334455 so newDna%100 is 55 then newDna - newDna%100 is equal to 334400
            //  Sum 99 and have the last digits as 99
            newDna = newDna - newDna % 100 + 99;
        }
        //  With the function in ZombieFactory a new zombie is created. Just for now the new zombie has no name
        _createZombie("NoName", newDna);
        //  Because the zombie has fed his cooldown is set
        _triggerCooldown(myZombie);
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
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }   
}
