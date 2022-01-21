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
    
    //  Mapping to link a hash with a integer number. It will link the students ID with them marks
    mapping (bytes32 => uint) qualification;
    
    //  Students can request a review. The name of the student requesting the review will be stored in the array
    string [] student_request;
    
    //  Events 
    event Evaluated_Student(bytes32);
    event Review_Request(string);

//  -------------------------------------------------------------------- MODIFIER & AUX FUNCTIONS -----------------------------------------------------

    /*  Only proffessor can execute the functions that have this modifier
        _sender: address 
    */
    modifier OnlyProffessor(address _executingAddress){
        require(_executingAddress == proffessor, "This address don't have permissions to execute this function.");
        _;
    }

//  -------------------------------------------------------------------- FUNCTIONS --------------------------------------------------------------------

    // Funcion para evaluar a alumnos
    function Evaluar(string memory _idAlumno, uint _nota) public UnicamenteProfesor(msg.sender){
        // Hash de la identificacion del alumno 
        bytes32 hash_idAlumno = keccak256(abi.encodePacked(_idAlumno));
        // Relacion entre el hash de la identificacion del alumno y su nota
        Notas[hash_idAlumno] = _nota;
        // Emision del evento
        emit alumno_evaluado(hash_idAlumno);
    }
    

    
    // Funcion para ver las notas de un alumno 
    function VerNotas(string memory _idAlumno) public view returns(uint) {
        // Hash de la identificacion del alumno 
        bytes32 hash_idAlumno = keccak256(abi.encodePacked(_idAlumno));
        // Nota asociada al hash del alumno
        uint nota_alumno = Notas[hash_idAlumno];
        // Visualizar la nota 
        return nota_alumno;
    } 
    
    // Funcion para pedir una revision del examen
    function Revision(string memory _idAlumno) public {
        // Almacenamiento de la identidad del alumno en un array
        revisiones.push(_idAlumno);
        // Emision del evento 
        emit evento_revision(_idAlumno);
    }
    
    // Funcion para ver los alumnos que han solicitado revision de examen
    function VerRevisiones() public view UnicamenteProfesor(msg.sender) returns (string [] memory){
        // Devolver las identidades de los alumnos
        return revisiones;
    }
    
}
