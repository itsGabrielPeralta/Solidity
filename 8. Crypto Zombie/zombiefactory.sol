pragma solidity ^0.4.19;

//  Main contract
contract ZombieFactory {
    
    // Event
    event NewZombie(uint zombieId, string name, uint dna);
    
    //  The DNA of the zombies will be defined by 16 digits. The next variable is for save this value
    uint dnaDigits = 16;
    //  Exponential variable of dnaDigits
    uint dnaModulus = 10 ** dnaDigits;
    
    //  Struct variable to define the zombies
    struct Zombie {
        string name;
        uint dna;
    }
    
    // The zombies will be storage in array so the proposal of the next variable is this. It's public so everyone can see the zombies
    Zombie[] public zombies;
    
    //  The key is the zombie ID and the value is the address who owned such zombie
    mapping (uint => address) zombieToOwner;
    //  The key is address and the value is the amount of zombie that the key address owned
    mapping (address => uint) ownerZombieCount;
    
    /*  Function to create zombie. This function has internal modifier in order to be called on another contracts that inherits from this contract.
        _name: zombie name
        _dna: zombie DNA
    */
    function _createZombie(string _name, uint _dna) internal {
        //  With the function parameter it's created a new zombie and added into the zombies array
        //  The position in array will be de zombie ID
        //  Get the array length and subtract 1 (because the array start with index 0) to know in what position has been saved the last zombie
        //  Create and add new zombie to the array and get the ID at the same time
        uint id = zombies.push(Zombie(_name, _dna)) - 1;
        // To set the zombie owner it's used the mapping defined before to set this relationship id => owner. The owner is the address who executes the function
        zombieToOwner[id] = msg.sender;
        // How this address is owner of a new zombie the count has increased in one unit
        ownerZombieCount[msg.sender]++;
        //  Emit the new zombie event
        emit NewZombie(id, _name, _dna);
    }
    
    /*  Function to generate a random DNA for zombie
        _str: string to hash
    */
    function _generateRandomDna(string _str) private view returns(uint) {
        // Get a rand integer number realizing hash in variable _str and converting it to uint
        uint rand = uint(keccak256(_str));
        // To ensure that rand have only 16 digits it's applied the module operation with danModulus variable and returns the value
        return rand % dnaModulus;
    }
    
    /*  Function to generate a random zombie with parameters introduced
        _name: zombie name
    */
    function createRandomZombie(string _name) public {
        // Each address only can create one zombie so if the zombie owned by the address executer is higher than 0 it can't execute this function again
        require(ownerZombieCount[msg.sender] == 0);
        //  Get the random DNA using _generateRandomDna function
        uint randDna = _generateRandomDna(_name);
        //  Generate the zombie using _createZombie function
        _createZombie(_name, randDna);   
    }
}
