/**
 *Submitted for verification at BscScan.com on 2022-05-17 09:05
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "./ERC20.sol";

contract Bitxcoin is ERC20, Ownable {
    address payable public stakeAddress =
        payable(0xC68F484857d74cb1A2Ed3Cd5203E8aF1Fbb8293B);

    bool takeStakeFees = false;

    constructor() ERC20("Bitxcoin", "BITX") {
        _mint(liquidityWallet, 59142504 * 10**8 );
        _mint(marketingWallet, 3900000 * 10**8 );
        _mint(strategicSalesWallet, 10000000 * 10**8 );
        _mint(gameOperationsWallet, 20000000 * 10**8 );
        _mint(teamWallet, 10000000 * 10**8 );
        _mint(communityAirdropWallet, 54385008 * 10**8 );
        _mint(Publicsale, 20000000 * 10**8 );

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[liquidityWallet] = true;
        _isExcludedFromFee[privateSaleWallet] = true;
        _isExcludedFromFee[marketingWallet] = true;
        _isExcludedFromFee[strategicSalesWallet] = true;
        _isExcludedFromFee[gameOperationsWallet] = true;
        _isExcludedFromFee[teamWallet] = true;
        _isExcludedFromFee[communityAirdropWallet] = true;
        _isExcludedFromFee[burnWallet] = true;
        _isExcludedFromFee[Publicsale] = true;
        _isExcludedFromFee[address(this)] = true;

        _includeInSell[owner()] = true;
        _includeInSell[liquidityWallet] = true;
        _includeInSell[privateSaleWallet] = true;
        _includeInSell[marketingWallet] = true;
        _includeInSell[strategicSalesWallet] = true;
        _includeInSell[gameOperationsWallet] = true;
        _includeInSell[teamWallet] = true;
        _includeInSell[communityAirdropWallet] = true;
        _includeInSell[burnWallet] = true;
         _includeInSell[Publicsale] = true;
        _includeInSell[address(this)] = true;

        pancakeRouter = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        pancakePair = IFactory(pancakeRouter.factory()).createPair(
            address(this),
            pancakeRouter.WETH()
        );

        setStakeAddress(stakeAddress);

        maxTxAmount = 110000 * 10**8 ;
    }

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function excludeFromSell(address account) external onlyOwner {
        _includeInSell[account] = false;
    }

    function includeInSell(address account) external onlyOwner {
        _includeInSell[account] = true;
    }

    //to recieve ETH from pancakeRouter when swaping
    receive() external payable {}

    function badActorDefenseMechanism(address account, bool isBadActor)
        external
        onlyOwner
    {
        _isBadActor[account] = isBadActor;
    }

    function checkBadActor(address account) public view returns (bool) {
        return _isBadActor[account];
    }

    function rescueBNBFromContract() external onlyOwner {
        address payable _owner = payable(msg.sender);
        _owner.transfer(address(this).balance);
    }

    function manualSwap() external onlyOwner {
        uint256 tokensToSwap = balanceOf(address(this));
        swapTokensForBNB(tokensToSwap);
    }

    function setStakeFeesFlag(bool flag) external {
        takeStakeFees = flag;
    }

    function staking(uint256 _amount) external {
        require(_amount <= balanceOf(_msgSender()), "Insufficent Balance");
        _transfeTokens(
            _msgSender(),
            stakeAddress,
            _amount,
            takeStakeFees,
            false
        );
    }

    function manualSend() external onlyOwner {
        swapAndSendToFees(balanceOf(address(this)));
    }

    function setmaxTxAmount(uint256 _maxTxAmount) external onlyOwner {
        maxTxAmount = _maxTxAmount;
    }

    function setBurnWallet(address payable _address)
        external
        onlyOwner
        returns (bool)
    {
        burnWallet = _address;
        _isExcludedFromFee[burnWallet] = true;
        _includeInSell[burnWallet] = true;

        return true;
    }

    function whitelistWallet(address payable _address) internal {
        _isExcludedFromFee[_address] = true;
        _includeInSell[_address] = true;
    }

    function setMarketingWallet(address payable _address)
        external
        onlyOwner
        returns (bool)
    {
        marketingWallet = _address;
        whitelistWallet(marketingWallet);
        return true;
    }

    function setLiquidityWallet(address payable _address)
        external
        onlyOwner
        returns (bool)
    {
        liquidityWallet = _address;
        whitelistWallet(liquidityWallet);
        return true;
    }

    function setAirdropWallet(address payable _address)
        external
        onlyOwner
        returns (bool)
    {
        communityAirdropWallet = _address;
        whitelistWallet(communityAirdropWallet);
        return true;
    }

    function setPrivateSaleWallet(address payable _address)
        external
        onlyOwner
        returns (bool)
    {
        privateSaleWallet = _address;
        whitelistWallet(privateSaleWallet);
        return true;
    }

    function setStrategicSalesWallet(address payable _address)
        external
        onlyOwner
        returns (bool)
    {
        strategicSalesWallet = _address;
        whitelistWallet(strategicSalesWallet);
        return true;
    }

    function setGameOperationsWallet(address payable _address)
        external
        onlyOwner
        returns (bool)
    {
        gameOperationsWallet = _address;
        whitelistWallet(gameOperationsWallet);
        return true;
    }

    function setTeamWallet(address payable _address)
        external
        onlyOwner
        returns (bool)
    {
        teamWallet = _address;
        whitelistWallet(teamWallet);
        return true;
    }
    function setPublicsale(address payable _address)
        external
        onlyOwner
        returns (bool)
    {
        Publicsale = _address;
        whitelistWallet(Publicsale);
        return true;
    }

    function setBurnDifference(uint256 _burnDifference) external onlyOwner {
        burnDifference = _burnDifference;
    }

    function setMaxBurnAmount(uint256 _maxBurnAmount) external onlyOwner {
        maxBurnAmount = _maxBurnAmount;
    }

    function UserLock(address Account, bool mode) external onlyOwner {
        LockList[Account] = mode;
    }

    function LockTokens(address Account, uint256 amount) external onlyOwner {
        LockedTokens[Account] = amount;
    }

    function UnLockTokens(address Account) external onlyOwner {
        LockedTokens[Account] = 0;
    }

    // Follwoing are the setter function of the contract  :

    function setTimeLimit(uint256 value) external onlyOwner {
        timeLimit = value;
    }

    function setMaxSellPerDayLimit(uint256 value) external onlyOwner {
        maxSellPerDayLimit = value;
    }

    function setStakeAddress(address payable _address) public onlyOwner {
        stakeAddress = _address;
    }

    function setBuylimit(uint256 limit) external onlyOwner {
        buyLimit = limit;
    }

    function setSelllimit(uint256 limit) external onlyOwner {
        sellLimit = limit;
    }

    function setBuyFees(
        uint256 taxFee,
        uint256 burnFee,
        uint256 airdropFee,
        uint256 marketingFee,
        uint256 liquidityFee
    ) external onlyOwner {
        buyFees.taxFee = taxFee; // tax
        buyFees.burnFee = burnFee;
        buyFees.airdropFee = airdropFee;
        buyFees.marketingFee = marketingFee;
        buyFees.liquidityFee = liquidityFee;
        buyFees.swapFee = marketingFee + airdropFee + burnFee + liquidityFee;
        require(
            buyFees.swapFee + buyFees.taxFee == 10000,
            "sum of all percentages should be 10000"
        );
    }

    function setRouterAddress(address newRouter) external onlyOwner {
        require(address(pancakeRouter) != newRouter, "Router already set");
        //give the option to change the router down the line
        IRouter _newRouter = IRouter(newRouter);
        address get_pair = IFactory(_newRouter.factory()).getPair(
            address(this),
            _newRouter.WETH()
        );
        //checks if pair already exists
        if (get_pair == address(0)) {
            pancakePair = IFactory(_newRouter.factory()).createPair(
                address(this),
                _newRouter.WETH()
            );
        } else {
            pancakePair = get_pair;
        }
        pancakeRouter = _newRouter;
    }

    function setTotalBuyFees(uint256 _totFees) external onlyOwner {
        buyFees.totFees = _totFees;
    }

    function setMaxSellAmountPerDay(uint256 amount) external onlyOwner {
        maxSellPerDay = amount * 10**8;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function isIncludeInSell(address account) public view returns (bool) {
        return _includeInSell[account];
    }

    function setliquiFlag() external onlyOwner {
        liquiFlag = !liquiFlag;
    }

    function airdrop(
        address[] calldata _contributors,
        uint256[] calldata _balances
    ) external onlyOwner {
        uint8 i = 0;
        for (i; i < _contributors.length; i++) {
            _transfer(owner(), _contributors[i], _balances[i]);
        }
    }

    function preSale(
        address[] calldata _contributors,
        uint256[] calldata _balances
    ) external onlyOwner {
        uint8 i = 0;
        for (i; i < _contributors.length; i++) {
            _transfer(owner(), _contributors[i], _balances[i]);
        }
    }

    function rescueBEPTokenFromContract() external onlyOwner {
        IERC20 ERC20Token = IERC20(address(this));
        address payable _owner = payable(msg.sender);
        ERC20Token.transfer(_owner, address(this).balance);
    }
}
