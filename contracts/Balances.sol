pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IVaultBeefy.sol";
import "./interfaces/IVaultYielfWolf.sol";
import "./interfaces/IMansonary.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IRewardPool.sol";

contract Balances is Ownable {

  IMasonry[] public banks;
  IERC20 public pae;
  IUniswapV2Pair public paeLp;
  IRewardPool public paeRewardPool;
  IVaultBeefy public paeBeefyVault;
  IVaultYieldWolf public wolfVault;
  uint256[] public wolfBankPids;
  uint256 public wolfLpPid;
  uint256 public rewardPoolIndex = 1;
  bool public isToken0;

  constructor (
    IMasonry[] memory _banks,
    IRewardPool _paeRewardPool,
    IVaultBeefy _beefyVault,
    IVaultYieldWolf _wolfLpVault,
    uint256 _wolfLpPid,
    uint256[] memory _wolfBankPids
  ) public {
    banks = _banks;
    paeLp = IUniswapV2Pair(_beefyVault.want());
    paeRewardPool = _paeRewardPool;
    paeBeefyVault = _beefyVault;
    wolfVault = _wolfLpVault;
    wolfLpPid = _wolfLpPid;
    wolfBankPids = _wolfBankPids;

    pae = IERC20(_paeRewardPool.pae());
    if (paeLp.token0() == address(pae)) isToken0 = true;
    else if (paeLp.token1() == address(pae)) isToken0 = false;
    else revert("not PAE LP");
  }

  function balanceOf(address account) external view returns (uint256) {
    uint256 lpBalance = paeLp.balanceOf(account);
    (uint256 poolBalance,) = paeRewardPool.userInfo(rewardPoolIndex, account);
    lpBalance = lpBalance + poolBalance + balanceBeefyLP(account) + balanceWolfLP(account);
    uint balanceInLps = lpBalance * paePerLP() / 1e18;

    return balanceInLps + pae.balanceOf(account) + balanceOfBanks(account) + balanceWolfBank(account);
  }

  function balanceOfBanks(address account) public view returns (uint256) {
    uint256 bal;
    for (uint256 i; i < banks.length; i++) {
      bal += banks[i].balanceOf(account);
    }
    return bal;
  }

  function balanceBeefyLP(address account) public view returns (uint256) {
    if (address(paeBeefyVault) == address(0)) return 0;
    return paeBeefyVault.balanceOf(account) * paeBeefyVault.getPricePerFullShare() / 1e18;
  }

  function balanceWolfLP(address account) public view returns (uint256) {
    if (address(wolfVault) == address(0)) return 0;
    return wolfVault.stakedTokens(wolfLpPid, account);
  }

  function balanceWolfBank(address account) public view returns (uint256) {
    if (address(wolfVault) == address(0)) return 0;
    uint256 bal;
    for (uint256 i; i < wolfBankPids.length; i++) {
      bal += wolfVault.stakedTokens(wolfBankPids[i], account);
    }
    return bal;
  }

  function paePerLP() public view returns (uint256) {
    (uint256 reserveA, uint256 reserveB,) = paeLp.getReserves();
    uint256 paeBalance = isToken0 ? reserveA : reserveB;
    return paeBalance * 1e18 / paeLp.totalSupply();
  }

  function setBanks(IMasonry[] memory _banks) external onlyOwner {
    banks = _banks;
  }

  function setBeefyVault(IVaultBeefy _beefyVault) external onlyOwner {
    paeBeefyVault = _beefyVault;
  }

  function setYieldWolfVault(IVaultYieldWolf _wolfVault, uint256 _lpPid, uint256[] memory _bankPids) external onlyOwner {
    wolfVault = _wolfVault;
    wolfLpPid = _lpPid;
    wolfBankPids = _bankPids;
  }
}
