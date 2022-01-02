#### Minimum Viable Automated Market Maker (MVAMM)

This repo holds solidity code (`^0.8.10`) for a very simple automated market maker. A demo jupyter notebook makes you then able to start quickly playing with it.

#### Setup

It was built with [truffle](https://trufflesuite.com/docs/index.html) and deployed using [ganache](https://trufflesuite.com/ganache/). `python` notebook code uses [web3py](https://web3py.readthedocs.io/en/stable/index.html). `requirements.txt` holds the different python deps needed for your environment.

Add OpenZeppelin and compile your contracts. You can then start jupyter and head to the `notebooks/mvamm.ipynb` notebook for deploying and interacting with your contract.

I tried to keep it as simple as possible. No requirements checks, no tests. Only barebone code and comments. Hence the Minimum Viable Automated Market Maker (MVAMM) name. 

#### What you can do

It performs three operations:

1. Liquidity updates. Initiate, add or remove liquidity.
2. Token prices calculations.
3. Token swaps.

Implementing and/or playing with this will make you learn about:

- Liquidity pools, how liquidity is added, removed and tracked
- ERC20 tokens, how to deploy, get balances, transfer, approve
- Maths in solidity (floats, units of measure (wei, ether, ..))
- Deploying and interacting with a smart contract using web3 library
- OpenZeppelin library

**Do not use it for any production purposes!** 

#### Readings

Some cool articles/resources for learning:

- [Uniswap V1](https://hackmd.io/@HaydenAdams/HJ9jLsfTz)
- [Uniswap V2](https://uniswap.org/whitepaper.pdf)
- [Uniswap V3](https://uniswap.org/whitepaper-v3.pdf)
- [Formal Specification of Constant Product Market Maker Model and Implementation](https://github.com/runtimeverification/verified-smart-contracts/blob/master/uniswap/x-y-k.pdf)
- [Uniswap doc](https://docs.uniswap.org/protocol/V2/introduction)
- [Maths in Solidity](https://medium.com/coinmonks/math-in-solidity-part-1-numbers-384c8377f26d)
- [Floats in Solidity](https://ethereum.stackexchange.com/questions/83785/what-fixed-or-float-point-math-libraries-are-available-in-solidity)
- [Damn vulnerable DeFi](https://www.damnvulnerabledefi.xyz/)
