// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.16;

import "./UniswapV2.sol";

interface ERC20 {
    function transferFrom(address, address, uint) external;
    function transfer(address, uint) external;
    function approve(address, uint) external;
    function balanceOf(address) external view returns (uint);
}

interface Master {
    function poolInfo(uint256 id) external returns (
        address lpToken,
        uint256 allocPoint,
        uint256 lastRewardBlock,
        uint256 accSushiPerShare
    );
}

contract MasterHelper {

    Master public constant master = Master(0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd);
    UniswapV2Router public constant router = UniswapV2Router(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);

    function swapTokenForPoolToken(uint256 poolId, address tokenIn, uint256 amountIn, uint256 minAmountOut) external {
        (address lpToken,,,) = master.poolInfo(poolId);
        address tokenOut0 = UniswapV2Pair(lpToken).token0();
        address tokenOut1 = UniswapV2Pair(lpToken).token1();

        ERC20(tokenIn).approve(address(router), type(uint256).max);
        ERC20(tokenOut0).approve(address(router), type(uint256).max);
        ERC20(tokenOut1).approve(address(router), type(uint256).max);
        ERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);

        // swap for both tokens of the lp pool
        _swap(tokenIn, tokenOut0, amountIn / 2);
        _swap(tokenIn, tokenOut1, amountIn / 2);

        // add liquidity and give lp tokens to msg.sender
        _addLiquidity(tokenOut0, tokenOut1, minAmountOut);
    }

    function _addLiquidity(address token0, address token1, uint256 minAmountOut) internal {
        (,, uint256 amountOut) = router.addLiquidity(
            token0, 
            token1, 
            ERC20(token0).balanceOf(address(this)), 
            ERC20(token1).balanceOf(address(this)), 
            0, 
            0, 
            msg.sender, 
            block.timestamp
        );
        require(amountOut >= minAmountOut);
    }

    function _swap(address tokenIn, address tokenOut, uint256 amountIn) internal {
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        router.swapExactTokensForTokens(
            amountIn,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}