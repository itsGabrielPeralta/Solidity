// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 < 0.7.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";

contract Disney {

// --------------------------------------------------------------------- DECLARACIONES INICIALES -----------------------------------------------
    // Instancia del contrato de los token
    ERC20Basic private token;

    // Variable de la dirección del owner. Será una dirección para pagos también
    address payable public owner;

    // Constructor
    constructor() public {
        token = new ERC20Basic(10000);
        owner = msg.sender;
    }

    // Estructura de datos para almacenar a los clientes de Disney
    struct cliente {
        uint tokens_comprados;
        string[] atracciones_disfrutadas;
    }

    // Mapping para el registro de clientes
    mapping(address => cliente) public Clientes;

// ------------------------------------------------------------------- GESTIÓN DE TOKENS -------------------------------------------------------

    // Función para establecer el precio de un token
    function PrecioTokens(uint _numTokens) internal pure returns (uint) {
        // Conversión de Tokens a Ethers: 1 Token -> 1 Ether
        return _numTokens*(1 ether);
    }

    // Función para comprar tokens
    function CompraTokens(uint _numTokens) public payable {
        // Establecer el precio de los Tokens
        uint coste = PrecioTokens(_numTokens);
        // Se comprueba el dinero que el cliente paga por los tokens
        require(msg.value >= coste, "Compra menos Tokens o pon más Ether");
        // Diferencia de lo que el cliente paga
        uint returnValue = msg.Value - coste;
        // Disney retorna la cantidad de Ethers al cliente
        msg.sender.transfer(returnValue);
        // Obtener el balance de Tokens disponibles
        uint balance = balanceOf();
        require(_numTokens <= balance, "Compra un número menor de Tokens");
        // Se transfiere el número de Tokens al cliente
        token.transfer(msg.sender, _numTokens);
        // Registro de tokens comprados
        Clientes[msg.sender].tokens_comprados += _numTokens;
    }

    // Balance de tokens del contrato
    function balanceOf() public view return(uint) {
        // Se le pasa la dirección de este contrato al método del contrato del Token para que indique el balance
        return token.balanceOf(address(this));
    }

    // Función para que cada persona pueda consultar el número de tokens que tiene
    function MisTokens() public view return(uint) {
        return token.balanceOf(msg.sender);
    }

    // Función para generar más tokens
    function GeneraTokens(uint _numTokens) public Unicamente(msg.sender) {
        token.increaseTotalSuply(_numTokens);
    }

    // Modificador para controlar las funciones ejecutables por Disney
    modifier Unicamente(address _direccion) {
        require(_direccion == owner, "No tienes permisos para ejecutar esta función");
        _;
    }

// -------------------------------------------------------------------------- GESTIÓN DE DISNEY -----------------------------------------------------

    // Eventos
    event disfruta_atraccion(string);
    event nueva_atraccion(string, uint);
    event baja_atraccion(string);

    // Estructura de datos de la atraccion
    struct atraccion {
        string nombre_atraccion;
        uint precio_atraccion;
        bool estado_atraccion;
    }

    // Mapping para relacionar un nombre de una atracción con una estructura de datos de la atracción
    mapping (string => atraccion) public MappingAtracciones;

    // Array para almacenar el nombre de las atracciones
    string[] Atracciones;

    // Mapping para relacionar una identidad con su historial
    mapping(address => string[]) HistorialAtracciones;

    // Función para añadir atracciones
    function NuevaAtraccion(string memory _nombreAtraccion, uint _precio) public Unicamente(msg.sender) {
        // Creación de una atracción
        MappingAtracciones[_nombreAtraccion] = atraccion(_nombreAtraccion, _precio, true);
        // Almacenar en el array de atracciones el nombre
        Atracciones.push(_nombreAtraccion);
        // Emisión de evento para nueva atracción
        emit nueva_atraccion(_nombreAtraccion, _precio);
    }

    // Función para dar de baja una atracción
    function BajaAtraccion(string memory _nombreAtraccion) public Unicamente(msg.sender) {
        // El estado de la atracción pasa a false
        MappingAtracciones[_nombreAtraccion].estado_atraccion = false;
        // Emisión del evento para la baja de la atracción
        emit baja_atraccion(_nombreAtraccion);
    }

    // Función para visualizar las atracciones
    function AtraccionesDisponibles() public view returns(string[] memory) {
        return Atracciones;
    }

    // Función para subirse a una atracción y pagar en tokens
    function SubirseAtraccion(string memory _nombreAtraccion) public {
        // Cuanto vale la atracción en tokens
        uint tokens_atraccion = MappingAtracciones[_nombreAtraccion].precio_atraccion;
        // Verifica el estado de la atracción
        require(MappingAtracciones[_nombreAtraccion].estado_atraccion == true, "La atracción no está disponible en estos momentos");
        // Verificar el número de tokens que tiene el cliente para subirse a la atracción
        require(tokens_atraccion <= MisTokens(), "Necesitas más tokens para subirte a esta atracción");
        /* El cliente paga la atracción en tokens. Ha sido necesario crear una función en ERC20.sol con el nombre de transferencia_disney
            debigo a que de haber usar el transfer o transferFrom se coge la dirección del contrato y esto no es la dirección de quien va a pagar
        */
        token.transferencia_disney(msg.sender, address(this), tokens_atraccion);
        // Almacenar en el historial de las atracciones del cliente
        HistorialAtracciones[msg.sender].push(_nombreAtraccion);
        // Emisión del evento para disfrutar de la atracción
        emit disfruta_atraccion(_nombreAtraccion, tokens_atraccion);

    }

    // Visualizar el historial completo de atracciones disfrutadas por un cliente
    function Historial() public view returns(strings[] memory) {
        return HistorialAtracciones[msg.sender];
    }

    // Función para devolver los tokens a ether
    function DevolverTokens(uint _numTokens) public payable {
        // El número de tokens a devolver es positivo
        require(_numTokens > 0, "Necesitas devolver una cantidad positiva de tokens");
        // El usuario debe de tener el número de tokens que desea devolver
        require(_numTokens < = MisTokens(), "No tienes los tokens que deseas devolver.");
        // El cliente devuelve los tokens
        token.returnToken(msg.sender, address(this), _numTokens);
        // Devolución de los ether al cliente
        msg.sender.transfer(PrecioTokens(_numTokens));
    }

}
