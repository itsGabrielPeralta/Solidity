// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 < 0.7.0;
pragma experimental ABIEncoderV2;

/*  Program to evaluate a group of students

    Examples data to prove
    ------------------------------------------------------
    STUDENTS  |    ID         |      QUALIFICATION
    ------------------------------------------------------
    Antonio   |    24907468D  |      7
    Lucas     |    54674262L  |      4
    Javier    |    06360382P  |      2
    Lucia     |    83897375E  |      9
    Victoria  |    28768985X  |      8
*/

contract evaluation {
    
//  -------------------------------------------------------------------- INITIAL PARAMETER ----------------------------------------------------------

    //  Proffesor address variable. The proffessor will be who executed de contract so he'll be the owner
    address public proffesor;
    
    //  Constructor that contains important parameters values
    constructor () public {
        //  The address that executed the contract is assigned to professor variable
        proffesor = msg.sender;
    }
    
    //  Mapping to link a hash with an integer number. It will link the students ID with them marks
    mapping (bytes32 => uint) qualification;
    
    //  Students can request a review. The name of the student requesting the review will be stored in the array
    string [] review_request;
    
    //  Events 
    event Evaluated_Student(bytes32);
    event Review_Request(string);

//  -------------------------------------------------------------------- MODIFIER & AUX FUNCTIONS -----------------------------------------------------

    /*  Only proffessor can execute the functions that have this modifier
        _executingAddress: address 
    */
    modifier OnlyProffessor(address _executingAddress){
        require(_executingAddress == proffessor, "This address don't have permissions to execute this function.");
        _;
    }

//  -------------------------------------------------------------------- FUNCTIONS --------------------------------------------------------------------

    /*  Function to evaluate the students
        _idStudent: ID of the student to be evaluated
        _qualification: student qualification
    */
    function Evaluate(string memory _idStudent, uint _qualification) public OnlyProffessor(msg.sender){
        // Get the hash of ID student
        bytes32 _hash_idStudent = keccak256(abi.encodePacked(_idStudent));
        // Link hash_idStudent with his qualification using qualification mapping
        qualification[_hash_idStudent] = _qualification;
        // Emits the evaluated student event
        emit Evaluated_Student(_hash_idStudent);
    }  
    
    /*  Function to see students' qualification 
        _idStudent: student's ID whose you want to consult
    */
    function ConsultQualification(string memory _idStudent) public view returns(uint _studentQualification) {
        // Get the hash of ID student
        bytes32 _hash_idStudent = keccak256(abi.encodePacked(_idStudent));
        // Get the student's qualification using the mapping that linked the id hash with the qualification
        _studentQualification = qualification[_hash_idStudent];
    } 
    
    /*  Function to request an exam review
        _idStudent: ID of the student who want to be reevaluated
    */
    function ReviewRequest(string memory _idStudent) public {
        // The student id requesting the review is added to the review request array
        review_request.push(_idAlumno);
        // Emits the event to indicate that a student has requested a review
        emit ReviewRequest(_idStudent);
    }
    
    // Function to view the students' history who have requested a review
    function ViewReviewRequest() public view OnlyProffessor(msg.sender) returns (string [] memory) {
        // Just return the array where the id of the students who have requested the review are add
        return review_request;
    }
}
