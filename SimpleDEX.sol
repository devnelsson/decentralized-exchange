// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

// Importa la interfaz estándar del token ERC20
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// Importa el contrato Ownable de OpenZeppelin para control de propiedad
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title SimpleDEX
/// @notice Exchange descentralizado simple con fórmula del producto constante
contract SimpleDEX is Ownable {
    // Referencias a los dos tokens ERC20 que serán intercambiados
    IERC20 public tokenA;
    IERC20 public tokenB;

    // Evento emitido al hacer un swap
    event TokenSwapped(address indexed user, string direction, uint256 amountIn, uint256 amountOut);
    // Evento emitido al agregar liquidez
    event LiquidityAdded(address indexed provider, uint256 amountTokenA, uint256 amountTokenB);
    // Evento emitido al remover liquidez
    event LiquidityRemoved(address indexed to, uint256 amountTokenA, uint256 amountTokenB);
	
	// Constructor que inicializa los tokens a intercambiar y asigna el owner
    constructor(address _tokenA, address _tokenB) Ownable(msg.sender) {
        // Verifica que las direcciones de los tokens no sean nulas
        require(_tokenA != address(0) && _tokenB != address(0), "Invalid token address");
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    /// @notice Agrega liquidez al pool
    /// @param amountA Cantidad de tokenA a agregar
    /// @param amountB Cantidad de tokenB a agregar
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        require(amountA > 0 && amountB > 0, "Amounts must be > 0");

        // Transfiere los tokens desde el proveedor al contrato
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        emit LiquidityAdded(msg.sender, amountA, amountB);
    }

    /// @notice El owner puede retirar liquidez del pool
    /// @param amountA Cantidad de tokenA a retirar
    /// @param amountB Cantidad de tokenB a retirar
    function removeLiquidity(uint256 amountA, uint256 amountB) external onlyOwner {
        // Verifica que haya suficiente liquidez en el contrato
        require(amountA <= tokenA.balanceOf(address(this)), "Not enough TokenA");
        require(amountB <= tokenB.balanceOf(address(this)), "Not enough TokenB");

        // Transfiere los tokens al owner
        tokenA.transfer(msg.sender, amountA);
        tokenB.transfer(msg.sender, amountB);

        emit LiquidityRemoved(msg.sender, amountA, amountB);
    }

    /// @notice Intercambia TokenA por TokenB usando fórmula del producto constante
    /// @param amountAIn Cantidad de TokenA a intercambiar
    function swapAforB(uint256 amountAIn) external {
        require(amountAIn > 0, "Amount must be > 0");

        // Obtiene las reservas actuales del pool
        uint256 reserveA = tokenA.balanceOf(address(this));
        uint256 reserveB = tokenB.balanceOf(address(this));

        // Calcula nuevas reservas usando la fórmula x * y = k
        uint256 newReserveA = reserveA + amountAIn;
        uint256 newReserveB = (reserveA * reserveB) / newReserveA;
        uint256 amountBOut = reserveB - newReserveB;

        // Verifica que haya suficiente liquidez de tokenB
        require(amountBOut <= reserveB, "Insufficient TokenB liquidity");

        // Realiza el swap
        tokenA.transferFrom(msg.sender, address(this), amountAIn);
        tokenB.transfer(msg.sender, amountBOut);

        emit TokenSwapped(msg.sender, "AtoB", amountAIn, amountBOut);
    }

    /// @notice Intercambia TokenB por TokenA usando fórmula del producto constante
    /// @param amountBIn Cantidad de TokenB a intercambiar
    function swapBforA(uint256 amountBIn) external {
        require(amountBIn > 0, "Amount must be > 0");

        // Obtiene las reservas actuales del pool
        uint256 reserveA = tokenA.balanceOf(address(this));
        uint256 reserveB = tokenB.balanceOf(address(this));

        // Calcula nuevas reservas usando la fórmula x * y = k
        uint256 newReserveB = reserveB + amountBIn;
        uint256 newReserveA = (reserveA * reserveB) / newReserveB;
        uint256 amountAOut = reserveA - newReserveA;

        // Verifica que haya suficiente liquidez de tokenA
        require(amountAOut <= reserveA, "Insufficient TokenA liquidity");

        // Realiza el swap
        tokenB.transferFrom(msg.sender, address(this), amountBIn);
        tokenA.transfer(msg.sender, amountAOut);

        emit TokenSwapped(msg.sender, "BtoA", amountBIn, amountAOut);
    }

    /// @notice Consulta el precio actual estimado de un token en términos del otro
    /// @param _token Dirección del token del cual se desea saber el precio
    /// @return Precio estimado del token en unidades del otro token
    function getPrice(address _token) external view returns (uint256) {
        uint256 balanceA = tokenA.balanceOf(address(this));
        uint256 balanceB = tokenB.balanceOf(address(this));

        // Verifica que el pool no esté vacío
        require(balanceA > 0 && balanceB > 0, "Pool vacio");

        // Calcula el precio dependiendo del token solicitado
        if (_token == address(tokenA)) {
            return (balanceB * 1e18) / balanceA; // Precio TokenA en términos de TokenB
        } else if (_token == address(tokenB)) {
            return (balanceA * 1e18) / balanceB; // Precio TokenB en términos de TokenA
        } else {
            revert("Token no se encuentra en el POOL");
        }
    }
}
