pragma solidity ^0.4.19;
import "./zombiehelper.sol";

contract ZombieBattle is ZombieHelper{

    //  Number to use on random number generation
    uint randNonce = 0;
    //  Probability of winning the battle for the attacking zombie
    uint attackVictoryProbability = 70;

    /*  Function to generate a random number to decide the winner battles
        _modulus: number to use as module
    */
    function randMod(uint _modulus) internal returns(uint) {
        //  Incread randNonce variable in order to use different number each execution
        randNonce = randNonce.add(1);
        //  Return the random number generated
        return uint(keccak256(now, msg.sender, randNonce)) % _modulus;
    }

    /*  Function to simulate a zombie attack
        _zombieId: attacking zombie ID
        _targetId: target zombie ID
    */
    function attack(uint _zombieId, uint _targetId) external onlyOwnerOf(_zombieId){
        //  Pointer variable declaration to have more accesible the zombies
        Zombie storage myZombie = zombies[_zombieId];
        Zombie storage enemyZombie = zombies[_targetId];
        //  Get a number whose range is 0-99 to decide the winner battle. In order to get a number between 0 and 99 the modulos has to be 100
        uint rand = randMod(100);
        //  If rand is lower or equal than attackVictoryProbability the winner is attacking zombie
        if(rand <= attackVictoryProbability){
            //  Increase the winner attacking zombie count
            myZombie.winCount = myZombie.winCount.add(1);
            //  Each victory implies going up a level
            myZombie.level = myZombie.level.add(1);
            //  Increase the loser target zombie count
            enemyZombie.lossCount = enemyZombie.lossCount.add(1);
            //  The winner feeds on the loser
            feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
        }
        else{
            myZombie.lossCount = myZombie.lossCount.add(1);
            enemyZombie.winCount = enemyZombie.winCount.add(1);
            _triggerCooldown(myZombie);
        }
        
    }

}
