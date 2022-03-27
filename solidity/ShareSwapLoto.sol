// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/FeedRegistryInterface.sol";
import "@chainlink/contracts/src/v0.8/Denominations.sol";

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";


contract ShareSwapLoto { 

    ISwapRouter private swapRouter;
    TransferHelper helper; 
    address uniswap; 
    uint24 poolFee = 3000;
    address chainlink; 
    address admin; 
    address self; 

    FeedRegistryInterface internal registry;

    constructor(address _chainlink, address _swapRouter, address _administrator) {
        admin = _administrator; 
        chainlink = _chainlink; 
        registry = FeedRegistryInterface(_chainlink);
        uniswap = _swapRouter; 
        swapRouter = ISwapRouter(_swapRouter);
        self = address(this);
    }

    function getWhatFriendGot(address _friendAddress) view external returns (uint256 _friendShare, uint256 swapAmount, string memory _friendAmount){

    }

    function shareSwapLoto(uint256 _shareAmount,  
                        address memory _erc20MyCurrency, 
                        address [] memory _friends, 
                        address [] memory _erc20TheirCurrencies) payable external returns (bool _done, uint256 _time){

        require(_friends.length < 6, "too many friends.");
        TransferHelper.safeTransferFrom(_erc20MyCurrency, msg.sender,self, _shareAmount);
        for(uint256 x = 0; x < _friends.length; x++){
            address friend_ = _friends[x];
            address friendErc20_ = _erc20TheirCurrencies[x];
            // split the share use vrf  
            uint256 random_ = getRandomNumber(); 
            uint256 share_ = (_shareAmount * random_) / 1e18;
            
            // get the price from Chainlink 
            uint256 price_ = getPrice(friendErc20_, _erc20MyCurrency);
            
            // make the swap and send to friend
            swapExactInputSingle(share_, _erc20MyCurrency, price_,  friend_, friendErc20_);
        }                                    
    }

    function swapExactInputSingle(uint256 _share, address _erc20MyCurrency, uint256 _price, address _friend, address _friendErc20) internal returns (uint256 _amountOut) {
                
        // Approve the router to spend 
        TransferHelper.safeApprove(_erc20MyCurrency, uniswap, amountIn);
        
        uint256 amountOutMinimum = _share * _price;        
        // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        ISwapRouter.ExactInputSingleParams memory params =
        ISwapRouter.ExactInputSingleParams({
            tokenIn: _erc20MyCurrency,
            tokenOut: _friendErc20,
            fee: poolFee,
            recipient: _friend,
            deadline: block.timestamp,
            amountIn: share,
            amountOutMinimum: amountOutMinimum,
            sqrtPriceLimitX96: 0
        });

        // The call to `exactInputSingle` executes the swap.
        _amountOut = swapRouter.exactInputSingle(params);
    }

    function getPrice(address base, address quote) internal view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = registry.latestRoundData(base, quote);
        return price;
    }

    function getRandomNumber() internal view returns (int) {

    }

}
