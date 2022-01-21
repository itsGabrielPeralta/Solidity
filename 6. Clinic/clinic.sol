// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

// Va a ser un contrato simulando a la OMS que contendrá varios contratos que representarán distintos centros, formando así una fábrica de contratos
contract OMS_COVID {

    // Dirección del propietario (OMS)
    address public direccion_OMS;

    // Constructor del contrato
    constructor() {
        direccion_OMS = msg.sender;
    }

    // Mapping para relacionar la dirección de los centro de salud con la validez del sistema de gestión. Si es true el centro de salud podrá crear contrato
    mapping(address => bool) validacion_centro;
    // Relacionar una dirección de centro de salud con su contrato. Introduciendo direccion del centro te devuelve la dirección del contrato correspondiente
    mapping(address => address) public centrosalud_contrato; 

    // Array de las direcciones de los contratos creados por los centros de salud
    address[] public direcciones_contratos_centros;
    // Array para almacenar los centros que solicitan entrar
    address[] solicitudes;

    // Eventos
    event SolicitudAcceso(address);
    event NuevoCentroValidado(address);
    event NuevoContrato(address, address);
    
    // Modificador para que sólo pueda ejecutar por el propietario (OMS)
    modifier SoloPropietario(address _direccion) {
        require(_direccion == direccion_OMS, "No tienes permisos para ejecutar esta funcion");
        _;
    }

    // Modificador para controlar que sólo los centros de salud ejecuten la función 
    modifier SoloCentrosValidados(address _direccion) {
        require(validacion_centro[_direccion] == true, "Este centro de salud no ha sido validado, por tanto no puede ejecutar esta funcion");
        _;
    }

    // Función para solicitar acceso a la OMS por parte de los centros
    function SolicitarAcceso() public {
        solicitudes.push(msg.sender);
        emit SolicitudAcceso(msg.sender);
    }

    // Función que visualiza las direcciones que han solicitado acceso 
    function VisualizarSolicitudes() public view SoloPropietario(msg.sender) returns(address[] memory) {
        return solicitudes;
    }

    // Función para validar nuevos centros de salud que puedan autogestionarse
    function ValidarCentro(address _centroSalud) public SoloPropietario(msg.sender) {
        validacion_centro[_centroSalud] = true;
        emit NuevoCentroValidado(_centroSalud);
    }

    // Función que permita crear un contrato inteligente
    function FactoryCentroSalud() public SoloCentrosValidados(msg.sender) {
        // Generar smart contract -> generar su dirección
        address contrato_centroSalud = address (new CentroSalud(msg.sender));
        // Se almacena la dirección de contrato en el array 
        direcciones_contratos_centros.push(contrato_centroSalud);
        centrosalud_contrato[msg.sender] = contrato_centroSalud;
        emit NuevoContrato(contrato_centroSalud, msg.sender);
    }




}

// Contrato de los centros de salud
contract CentroSalud {

    // Direcciones principales necesarias
    address public direccionCentroSalud;
    address public direccionContrato;

    constructor(address _direccion) {
        direccionCentroSalud = _direccion;
        direccionContrato = address(this);
    }

    struct resultadosCovid {
        bool diagnostico;
        string codigoIPFS;
    }

    // Mapping para relacionar el hash de la persona con los resultados (diagnostico, codigo ipfs)
    mapping (bytes32 => resultadosCovid) resultados;

    // Eventos 
    event NuevoResultado(bool, string);

    // Modificador para que sólo el centro de salud pueda ejecutar sus funciones 
    modifier SoloCentroSalud(address _direccion) {
        require(_direccion == direccionCentroSalud, "Solo el centro de salud propietario puede ejecutar esta funcion");
        _;
    }

    // Función para emitir un resultado de una prueba de covid 
    // DNI / true or false / código de ipfs
    function ResultadosPruebaCovid(string memory _idPersona, bool _resultadoCovid, string memory _codigoIPFS) public SoloCentroSalud(msg.sender) {
        // hash de la identificación de la persona
        bytes32 hash_idPersona = keccak256(abi.encodePacked(_idPersona));
        // Relación entre el hash de la persona y el resultado de la prueba y el código ipfs
        resultados[hash_idPersona] = resultadosCovid(_resultadoCovid, _codigoIPFS);
        emit NuevoResultado(_resultadoCovid, _codigoIPFS);
    }

    // Función para visualizar los resultados del covid 
    // En esta función se usa una forma distinta de hacer los return. Se pone la variable que se retorna en el propio return y basta con que luego se le de valor
    function VisualizarResultados(string memory _idPersona) public view returns(string memory _resultadoPrueba, string memory _codigoIPFS) {
        // hash de la identidad de la persona 
        bytes32 hash_idPersona = keccak256(abi.encodePacked(_idPersona));
        // retorno de un booleano como un string
        string memory resultadoPrueba;
        
        if(resultados[hash_idPersona].diagnostico == true)
            resultadoPrueba = "Positivo";
        else
            resultadoPrueba = "Negativo";

        _resultadoPrueba = resultadoPrueba;
        _codigoIPFS = resultados[hash_idPersona].codigoIPFS;
    }

}
