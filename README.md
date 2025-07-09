# SimpleDEX - Exchange Descentralizado en Scroll Sepolia

Este proyecto es una implementación de un **Exchange Descentralizado (DEX)** simple desplegado en la red de **Scroll Sepolia**, utilizando contratos inteligentes en Solidity. Permite el intercambio de dos tokens ERC-20 (TokenA y TokenB) mediante un **pool de liquidez** que aplica la fórmula del producto constante para calcular los precios de intercambio.


## Descripción del Proyecto

Este DEX básico fue desarrollado como parte de un trabajo académico para entender el funcionamiento de los intercambios descentralizados, la provisión de liquidez y la lógica de mercado automatizado (AMM).

La solución implementa:

-  Creación de dos tokens ERC-20 simples: **TokenA (TKA)** y **TokenB (TKB)**
-  Pool de liquidez manejado por el contrato `SimpleDEX`
-  Intercambio entre TokenA y TokenB usando la fórmula del producto constante
-  Funcionalidad para añadir y retirar liquidez (sólo por el `owner`)
-  Eventos para notificar las acciones del contrato

## Funcionalidades del SimpleDEX

| Función                                             | Descripción                                              |
| --------------------------------------------------- | -------------------------------------------------------- |
| `constructor(address _tokenA, address _tokenB)`     | Inicializa el DEX con las direcciones de TokenA y TokenB |
| `addLiquidity(uint256 amountA, uint256 amountB)`    | Permite al owner añadir pares de tokens al pool          |
| `removeLiquidity(uint256 amountA, uint256 amountB)` | Permite al owner retirar liquidez del pool               |
| `swapAforB(uint256 amountAIn)`                      | Usuario intercambia TokenA por TokenB                    |
| `swapBforA(uint256 amountBIn)`                      | Usuario intercambia TokenB por TokenA                    |
| `getPrice(address _token)`                          | Consulta el precio estimado de un token respecto al otro |

