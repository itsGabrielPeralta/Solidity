// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;

/*  Program to carry out an electoral process

    Examples data to prove
    ------------------------------------------------------
    CANDIDATE   |    ID         |      AGE
    ------------------------------------------------------
    Antonio     |    24907468D  |      40
    Lucas       |    54674262L  |      29
    Javier      |    06360382P  |      61
    Lucia       |    83897375E  |      90
    Victoria    |    28768985X  |      33
*/

contract voting{

///     --------------------------------------------------- INITIAL PARAMETERS -------------------------------------------------------

    //  Owner address variable
    address public owner;

    //  Constructor
    constructor() public {
        //  Address who execute the contract is assigned to owner variable
        owner = msg.sender;
    }

    //  Mapping to link a string with a hash. The relantionship will be between the name of the candidate and the hash of their data (name, id and age)
    mapping(string => bytes32) dataCandidate;

    //  Mapping to link a string with a integer number. The relantionship will be between the name of the candidate and their votes
    mapping(string => uint) votesCandidate;

    //  Array to storage the candidates' name 
    string[] candidates;

    //  Array to storage the address hash of the voters
    bytes32[] voters;

    //  Events
    event CandidatePresented(string, uint, string);

///     ------------------------------------------------------ MODIFIER & AUX FUNCTIONS -------------------------------------------------------------------

    /*  Modifier to control that each address can only vote once
        _addressVoter: address that executes the function
    */
    modifier OneVotePerAddress(address _addressVoter){
        // Because the stored voters data are the address' hash, the executer address' hash is obtained
        bytes32 hash_addressVoter = keccak256(abi.encodePacked(_addressVoter));
        // With for bucle the voters array is checked 
        for(uint i = 0 ; i < voters.length ; i++){
            // If the voter has voted before don't let the function execution
            require(voters[i] != hash_addressVoter, "You can't vote because you voted once before");
        }
        _;
    }

    /*  Aux function that convert an integer number into string
        _i: integer number to convert into string
    */
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

///     ------------------------------------------------------ FUNCTIONS -------------------------------------------------------------------

    /*  Function to present candidate
        Los datos personales de los candidatos se almacenan a través de su hash y se relacionan con su nombre ya que es a través de su nombre del modo en el que van a 
        quedar almacenados en un array.
        _name: candidate name
        _age: candidate age
        _id: candidate ID
    */
    function PresentCandidate(string memory _name, uint _age, string memory _id) public {
        // Get the hash of the candidate data
        bytes32 hash_candidate = keccak256(abi.encodePacked(_name, _age, _id));
        // With dataCandidate mapping the relationship between candidate name and their hash data is made
        dataCandidate[_name] = hash_candidate;
        // Add the candidate in the array
        candidates.push(_name);
    }

    //  Function to visualize the presented candidates
    function VisualizeCandidates() public view returns(string[] memory) {
        // Just return the candidates array where their names are stored
        return candidates;
    }

    /*  Function to vote a candidate
        _candidateName: candidate name to vote
    */
    function Votar(string memory _candidateName) public OneVotePerAddress(msg.sender){
        // A vote is add in the votes candidate mapping
        votesCandidate[_candidateName]++;
        // The hash of the voter's address is add in the voters array to control that this direction have voted and don't do it again
        bytes32 hash_candidateAddress = keccak256(abi.encodePacked(msg.sender));
        voters.push(hash_candidateAddress);
    }

    /* Function to consult a candidate votes
        _candidateName: candidate name whose votes will be given by this function
    */
    function VisualizeCandidateVotes(string memory _candidateName) public view returns(uint){
        // Just return the mapping of the candidate votes with the name introduced in the function execution
        return votesCandidate[_candidateName];
    }

    //  Function to consult the votes of each candidate  
    function VisualizeAllVotes() public view returns(string memory){     
        // string variable to add each candidate and the number of his votes
        string memory results;
        // For bucle to consult each index in the candidates array
        for(uint i = 0 ; i < candidates.length; i++){
            results = string(abi.encodePacked(results, "(", candidates[i], ", ", uint2str(VisualizeCandidateVotes(candidates[i])), ") --- "));
        }
        return results;
    }

    //  Function to select the winner
    function President() public view returns(string memory){
        // Winner variable that contains the firs candidate array position
        string memory president = candidates[0];
        // Variable to indicate if there is a draw
        bool draw;
        // For bucle to compare the candidates
        for(uint i = 1 ; i < candidates.length ; i++){
            // If the candidate votes in the i position of candidate array is higher than the candidate stored in the president variable, the value of this variable
            // is modified
            if(votesCandidate[president] < votesCandidate[candidates[i]]){
                president = candidates[i];
                draw = false;
            }
            else if (votesCandidate[president] == votesCandidate[candidates[i]])
                draw = true;         
        }

        if(draw)
            president = "There is a draw between candiddate!";
        
        // In draw case the variable that returns will be a message that indicate a draw 
        return president;
    }
}
