// SPDX-License-Identifier: MIT
pragma solidity >0.4.4 <=0.7.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";

contract loteria {

// ---------------------------------------------------------- DECLARACIONES INICIALES --------------------------------------------------

    // Instancia del contrato del token
    ERC20Basic private token;

    // Direcciones
    address public owner;
    address public contrato;

    // Número de tokens a crear
    uint public tokens_creados = 10000;
    // Precio de un token
    uint public precio_token = 1 ether;
    // Precio de un boleto en tokens
    uint public precio_boleto = 5;

    constructor() public {
        token = new ERC20Basic(tokens_creados);
        owner = msg.sender;
        contrato = address(this);
    }

    // Relación entre la persona que compra los boletos y el número del boleto 
    mapping(address => uint[]) idPersona_boletos;
    // Relación para identificar al ganador, relacionando el número ganador con la dirección
    mapping(uint => address) ADN_boleto;
    // Número aleatorio
    uint randNonce = 0;
    // Boletos generados
    uint[] boletos_comprados;

    // Eventos
    event boleto_comprado(uint, address);
    event boleto_ganador(uint);


// ---------------------------------------------------------- GESTIÓN TOKEN ---------------------------------------------------

    // Función para establecer el precio del token
    function PrecioToken (uint _numTokens) internal view returns(uint) {
        return _numTokens * precio_token;
    }

    // Función para generar más tokens
    function GenerarTokens (uint _numTokens) public SoloPropietario(msg.sender) {
        token.increaseTotalSupply(_numTokens);
    }

    // Función para comprar tokens
    function ComprarTokens(uint _numTokens) public payable ComprobarCompraToken(_numTokens) {
        // Calcular el precio de los tokens
        uint coste = PrecioToken(_numTokens);
        // Si se envía más ether del que se corresponde con los tokes que se piden se devuelven esos ether. Se crea variable para ello
        uint returnValue = msg.value - coste;
        // Transferencia de esta diferencia
        msg.sender.transfer(returnValue);
        // Transferencia de tokens al comprador
        token.transfer(msg.sender, _numTokens);
    }

    // Función para ver el balance del contrato
    function BalanceContrato() public view returns(uint) {
        return token.balanceOf(contrato);
    }

    // Función para obtener el balance de los tokens acumulados en el bote 
    function ConsultarBote() public view returns (uint) {
        // El bote se va a guardar en la dirección del propietario
        return token.balanceOf(owner);
    }

    // Función para que cada usuario vea su balance 
    function MisTokens() public view returns(uint) {
        return token.balanceOf(msg.sender);
    }

// ---------------------------------------------------------- GESTIÓN LOTERÍA ---------------------------------------------------

    // Función para comprar boletos 
    function ComprarBoletos(uint _numBoletos) public ComprobarCompraBoletos(_numBoletos) {
        // Se calcula el precio de los boletos en tokens
        uint precio_boletos = _numBoletos * precio_boleto;
        // Transferencia de tokens desde el usuario al propietario
        token.returnToken(msg.sender, owner, precio_boletos);
        // Asignar un número aleatorio a los boletos 
        for(uint i = 0 ; i < _numBoletos ; i++){
            /* Para simular la generación de un método aleatorio se toma la marca de tiempo actual, la dirección del usuario y un nonce para 
                realizar un hash de estos parámetros y se obtiene el módulo al dividir por 10000 para coger lo últimos 4 dígitos del hash dando un valor
                aleatorio entre 0-9999
            */
            uint random = uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % 10000;
            randNonce++; // Se aumenta el valor con cada ejecución de este bucle para que cada boleto comprado en este contrato sea distinto
            // Se almacena los datos en los boletos y se da por comprado 
            idPersona_boletos[msg.sender].push(random);
            // Se almacena en este mapping para poder seleccionar luego ganador
            ADN_boleto[random] = msg.sender;
            emit boleto_comprado(random, msg.sender);
        }
    }

    // Función para visualizar el usuario sus números de boleto 
    function MisBoletos() public view returns(uint[] memory) {
        return idPersona_boletos[msg.sender];
    }

    // Función para generar un ganador e ingresarle los tokens 
    function GenerarGanador() public SoloPropietario(msg.sender) {
        require(boletos_comprados.length > 0, "No hay boletos comprados");
        // Variable con el tamaño del array de boletos
        uint longitud = boletos_comprados.length;
        // Se escoge aleatoriamente una posición del array. Se hace con un uint de más por si el resultado es decimal quedarse con la parte entera del número 
        uint posicion_array = uint(uint(keccak256(abi.encodePacked(now))) % longitud);
        // Selección del número aleatorio mediante la posición del array
        uint eleccion = boletos_comprados[posicion_array];
        emit boleto_ganador(eleccion);
        // Variable con la dirección del ganador 
        address direccion_ganador = ADN_boleto[eleccion];
        // Enviarle los tokens del premio al ganador
        token.returnToken(msg.sender, direccion_ganador, ConsultarBote());
    }

    // Devolución de los tokens en ether 
    function DevolverTokensEther(uint _numTokens) public payable ComprobarDevolucionToken(_numTokens, msg.sender){
        token.returnToken(msg.sender, contrato, _numTokens);
        msg.sender.transfer(PrecioToken(_numTokens));
    }


// ---------------------------------------------------------- FUNCIONES AUXILIARES ----------------------------------------------

    // Modifier para requerir que sólo el propietario del contrato puede ejecutar la función
    modifier SoloPropietario(address _direccion) {
        require(_direccion == owner, "No tienes permisos para ejecutar esta funcion.");
        _;
    }

    // Modifier para requerir que el usuario tenga los Ether para asumir el coste
    modifier ComprobarCompraToken(uint _numTokens) {
        uint coste = PrecioToken(_numTokens);  // Variable del coste en ether de los tokens
        uint balanceContrato = BalanceContrato();         // Variable del número de tokens que hay en el contrato

        require(msg.value >= coste, "El ether que envías para comprar ese número de tokens es insuficiente");
        require(_numTokens > 0, "No has pedido un valor positivo de tokens");
        require(balanceContrato >= _numTokens, "No hay suficientes tokens en el contrato en este momento. Reduce el número de tokens o espera");
        _;
    }

    // Modefier para comprobar las condiciones al comprar boletos 
    modifier ComprobarCompraBoletos(uint _numBoletos) {
        // Se calcula el precio de los boletos en tokens
        uint precio_boletos = _numBoletos * precio_boleto;
        // Se requiere que el usuario tenga esa cantidad de tokens
        require(precio_boletos <= token.balanceOf(msg.sender), "No dispones de los suficientes tokens para esos boletos");
        _;
    }

    // Modifier para controlar la devolución de tokens a ether 
    modifier ComprobarDevolucionToken(uint _numTokens, address _direccion) {
        require(_numTokens > 0, "Se debe introducir una cantidad positiva de tokens");
        require(_numTokens <= token.balanceOf(_direccion), "No tienes los tokens que pretendes devolver");
        _;
    }

}
