//  TEST FILE USING JS, TRUFFLE & GANACHE
//  In the test folder generated with our contract compilation we create this test file

/*  Every time you compile a smart contract, the Solidity compiler generates a JSON file(referred to as build artifacts) 
which contains the binary representation of that contract and saves it in the build/contracts folder.
The first thing you'll need to do every time you start writing a new test suite is to load the build artifacts of the contract
 you want to interact with. This way, Truffle will know how to format our function calls in a way the contract will understand.
*/

//  Contract Artifact variable to test
const CryptoZombies = artifacts.require("CryptoZombies");

//  Array of zombies name to prove
const zombieNames = ["Zombie 1", "Zombie 2"];

//@dev      Contract function groups the tests. The test use the tool called Ganache that provide ten accounts with 100 eth each
//@param    string that indicate what to test
//@param    callback that is where we're going to actually write our tests    
 contract("CryptoZombies", (accounts) => {
     // Give name to two accounts given by ganache
     let[alice, bob] = accounts;
     it("should be able to create a new zombie", async () => {
         // Constract instance
         const contractInstance = await CryptoZombies.new();
     })
 })
