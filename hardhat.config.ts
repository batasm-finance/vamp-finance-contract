import '@nomiclabs/hardhat-etherscan';
import '@nomiclabs/hardhat-web3';
import 'dotenv/config';
import 'hardhat-deploy';
import 'hardhat-deploy-ethers';
import 'hardhat-gas-reporter';
import { HardhatUserConfig } from 'hardhat/types';
import { accounts } from './utils/networks';
import './utils/wellknown';

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: '0.6.12',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  networks: {
    hardhat: {
      accounts: accounts('localhost'),
    },
    localhost: {
      url: 'http://localhost:8545',
      accounts: accounts('localhost'),
    },
    kovan: {
      url: 'https://kovan.infura.io/v3/2ea633dc418f47988b997833974744c2',
      accounts: accounts('kovan'),
    },
    fantom: {
      url: 'https://rpc.ftm.tools/',
      chainId: 250,
      accounts: accounts('fantom'),
    },
    'fantom-test': {
      url: 'https://rpc.testnet.fantom.network/',
      chainId: 4002,
      accounts: accounts('fantom'),
    },
    avax: {
      url: 'https://api.avax.network/ext/bc/C/rpc',
      chainId: 43114,
      accounts: accounts('avax'),
    },
  },
  gasReporter: {
    currency: 'USD',
    gasPrice: 5,
    enabled: !!process.env.REPORT_GAS,
  },
  namedAccounts: {
    deployer: 0
  },
};

export default config;
