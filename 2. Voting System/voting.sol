// SPDX-License-Identifier: MIT
//pragma solidity ^0.8.0;
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;

/*
    Datos para probar candidatos
    -----------------------------------
    CANDIDATO   |   EDAD   |      ID
    -----------------------------------
    Toni        |    20    |    12345X
    Alberto     |    23    |    54321T
    Joan        |    21    |    98765P
    Javier      |    19    |    56789W
*/

contract votacion{

    /// --------------------------------------------------- DECLARACIÓN DE VARIABLES -------------------------------------------------------

    // Dirección del propietario del contrato
    address public owner;

    // Constructor
    constructor() public {
        owner = msg.sender;
    }

    // Relacionar el nombre del candidato y el hash de sus datos personales
    mapping(string => bytes32) id_candidato;

    // Relacionar el nombre del candidato y el número de votos
    mapping(string => uint) votos_candidato;

    // Lista para almacenar los nombres de los candidatos que se han presentado
    string[] candidatos;

    // Lista del hash de la dirección de los votantes
    bytes32[] votantes;

    /// ------------------------------------------------------ FUNCIONES -------------------------------------------------------------------

    /*  Función para presentarse candidato
        Los datos personales de los candidatos se almacenan a través de su hash y se relacionan con su nombre ya que es a través de su nombre del modo en el que van a 
        quedar almacenados en un array.
        _nombre: nombre del candidato
        _edad: edad del candidato
        _id: número de identificación del candidato
    */
    function PresentarCandidato(string memory _nombre, uint _edad, string memory _id) public {

        // Obtener el hash de los datos del candidato
        bytes32 hash_candidato = keccak256(abi.encodePacked(_nombre, _edad, _id));

        // Almacenar el hash de los datos del candidato que están ligados a su nombre
        id_candidato[_nombre] = hash_candidato;

        // Actualizar lista de los candidatos
        candidatos.push(_nombre);
    }

    /*  Función para ver los candidatos que se han presentado   
    */
    function VerCandidatos() public view returns(string[] memory) {
        return candidatos;
    }

    /*  Función para votar a los candidatos
        _candidato: nombre del candidato al que vota
    */
    function Votar(string memory _candidato) public UnVotoPorDireccion(msg.sender){
        // Se añade un voto al candidato seleccionado
        votos_candidato[_candidato]++;
        // Se incluye el hash del votante en el array de hash que ya han votado
        bytes32 hash_votante = keccak256(abi.encodePacked(msg.sender));
        votantes.push(hash_votante);
    }

    /* Función para ver los votos de un candidato
        _candidato: nombre del candidato del que se quiere consultar los votos
    */
    function VerVotos(string memory _candidato) public view returns(uint){
        return votos_candidato[_candidato];
    }

    /*  Función para ver los votos de cada candidato        
    */
    function VerResultados() public view returns(string memory){
        
        // Variable string que se almacenará los candidatos y sus respectivos votos
        string memory resultados;

        // Bucle para recorrer el array de candidatos e ir actualizando la variable string
        for(uint i = 0 ; i < candidatos.length; i++){
            resultados = string(abi.encodePacked(resultados, "(", candidatos[i], ", ", uint2str(VerVotos(candidatos[i])), ") --- "));
        }
    }

    /*  Función para dar el ganador de la votación
    */
    function Ganador() public view returns(string memory){
        // Se inicializa la variable del ganador. Se inicia con que el ganador es el de la primera posición
        string memory ganador = candidatos[0];

        // Variable para indicar si hay empate
        bool empate;

        // Se comparan los candidatos con un bucle for
        for(uint i = 1 ; i < candidatos.length ; i++){
            if(votos_candidato[ganador] < votos_candidato[candidatos[i]]){
                ganador = candidatos[i];
                empate = false;
            }
            else if (votos_candidato[ganador] == votos_candidato[candidatos[i]])
                empate = true;         
        }

        if(empate)
            ganador = "Hay un empate entre los candidatos!";
        
        // En caso de empate la variable ganador contendrá mensaje de texto indicando este suceso. Si no es empate contendrá el nombre del ganador
        return ganador;
    }

    /// ------------------------------------------------------ FUNCIONES AUXILIARES -------------------------------------------------------------------

    /*  Modificador para controlar que cada votante sólo pueda votar una única vez
        Dicho control se realizará a través del hash de las direcciones
        _direccion_votante: dirección que llama a la función
    */
    modifier UnVotoPorDireccion(address _direccion_votante){
        // Se obtiene el hash de la dirección que ejecuta la función
        bytes32 hash_votante = keccak256(abi.encodePacked(_direccion_votante));
        // Se verifica si esta dirección ya ha votado
        for(uint i = 0 ; i < votantes.length ; i++){
            require(votantes[i] != hash_votante, "Ya has votado previamente");
        }
        _;
    }

    //Funcion auxiliar que transforma un uint a un string
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
}
