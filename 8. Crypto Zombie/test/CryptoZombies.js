//  TEST FILE USING JS, TRUFFLE & GANACHE
//  In the test folder generated with our contract compilation we create this test file

/*  Every time you compile a smart contract, the Solidity compiler generates a JSON file(referred to as build artifacts) 
which contains the binary representation of that contract and saves it in the build/contracts folder.
The first thing you'll need to do every time you start writing a new test suite is to load the build artifacts of the contract
 you want to interact with. This way, Truffle will know how to format our function calls in a way the contract will understand.
*/

//  Contract Artifact variable to test
const CryptoZombies = artifacts.require("CryptoZombies");
//  Import the utils file to this test
const utils = require("./helpers/utils");
//  Import the time file to this test
const time = require("./helpers/time");
//  Array of zombies name to prove
const zombieNames = ["Zombie 1", "Zombie 2"];

//@dev      Contract function groups the tests. The test use the tool called Ganache that provide ten accounts with 100 eth each
//@param    string that indicate what to test
//@param    callback that is where we're going to actually write our tests    
 contract("CryptoZombies", (accounts) => {
    // Give name to two accounts given by ganache
    let[alice, bob] = accounts;

    // Contract instance variable. To limite the variable in scope to the block in which it's define use let instead of var
    let contractInstance;

    // The beforeEach method execute its code before the execution of every test. It's util for contract instance since every test
    // execution is a empty sheet if not you will have to define the contract instance on each test       
    beforeEach(async () => {
        // Constract instance definition
        contractInstance = await CryptoZombies.new();
    });    

    it("should be able to create a new zombie", async () => {
        // Method call to create a zombie. Second argument is the address who call the function
        const result = await contractInstance.createRandomZombie(zombieNames[0], {from: alice});
        // Check if the call is ok with assert command comparing the result status with bool true
        assert.equal(result.receipt.status, true);
        // Check if argument name in result variable is equal to the name passed with the function
        assert.equal(result.logs[0].args.name, zombieNames[0]);
    })
    
    it("should not allow two zombies", async () => {
        // First let Alice address create a zombie
        // Method call to create a zombie. Second argument is the address who call the function
        await contractInstance.createRandomZombie(zombieNames[0], {from: alice});
        // After let Alice address create a second zombie. This must throw an error because in our contract only allow create a zombie
        // In order to not write a lot throw/catch, this structure is in utils file
        await utils.shouldThrow(contractInstance.createRandomZombie(zombieNames[1], {from: alice}));
    })

    context("with the single-step transfer scenario", async () => {
        it("should transfer a zombie", async () => {
            //  Create zombie
            const result = await contractInstance.createRandomZombie(zombieNames[0], {from:alice});
            //  Get the zombie id
            const zombieId = result.logs[0].args.zombieId.toNumber();
            //  Transfer zombie from Alice to Bob
            await contractInstance.transferFrom(alice, bob, zombieId, {from: alice});
            //  Get the zombie owner
            const newOwner = await contractInstance.ownerOf(zombieId);
            //  Check if Bob is the owner
            assert.equal(newOwner, bob);
        })
    })
    //  Context is to unify the tests
    context("with the two-step transfer scenario", async () => {
        it("should approve and then transfer a zombie when the approved address calls transferFrom", async () => {
            //  Create zombie
            const result = await contractInstance.createRandomZombie(zombieNames[0], {from:alice});
            //  Get the zombie id
            const zombieId = result.logs[0].args.zombieId.toNumber();
            //  Call the approve function as alice
            await contractInstance.approve(bob, zombieId, from{alice});
            //  Transfer zombie from Alice to Bob what using this scenario that Alice approve Bob is Bob who call the transfer function
            await contractInstance.transferFrom(bob, alice, zombieId, {from: bob});
            //  Get the zombie owner
            const newOwner = await contractInstance.ownerOf(zombieId);
            //  Check if Bob is the owner
            assert.equal(newOwner, bob);
        })
        it("should approve and then transfer a zombie when the owner calls transferFrom", async () => {
                        //  Create zombie
            const result = await contractInstance.createRandomZombie(zombieNames[0], {from:alice});
            //  Get the zombie id
            const zombieId = result.logs[0].args.zombieId.toNumber();
            //  Call the approve function as alice
            await contractInstance.approve(bob, zombieId, from{alice});
            //  Transfer zombie from Alice to Bob
            await contractInstance.transferFrom(bob, alice, zombieId, {from: alice});
            //  Get the zombie owner
            const newOwner = await contractInstance.ownerOf(zombieId);
            //  Check if Bob is the owner
            assert.equal(newOwner, bob);
        })
    })

    it("zombies should be able to attack another zombie", async () => {
        let result;
        result = await contractInstance.createRandomZombie(zombieNames[0], {from: alice});
        const firstZombieId = result.logs[0].args.zombieId.toNumber();
        result = await contractInstance.createRandomZombie(zombieNames[1], {from: bob});
        const secondZombieId = result.logs[0].args.zombieId.toNumber();
        //  The zombies can't feed or attack twice on a day but this function simulate over time
        await time.increase(time.duration.days(1));
        await contractInstance.attack(firstZombieId, secondZombieId, {from: alice});
        assert.equal(result.receipt.status, true);
    })
 })
