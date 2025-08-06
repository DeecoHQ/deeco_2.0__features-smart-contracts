# Deeco 2.0.

Deeco is a onchain(blockchain) e-commerce project. In simple terms, it is a project that re-imagines and re-defines e-commerce, by introducing blockchain innovations and cryptocurrency adoption(for payments) - across multiple EVM chains.

This repository contains the smart-contract architecture and implementation for the project. Use this link to [view the planning and architectural modelling of the project](https://github.com/Okpainmo/deeco-2.0__smart-contracts?tab=readme-ov-file#smart-contract-architecture).

## Supported/Token Chains.

1. Ethereum(Ethereum Core).
2. Base.
3. Polygon.
4. Binance Smart Chain.
5. Arbitrum.

**N.B: Token support to include both native chain tokens and USDT wherever possible.**

## Setting up for local interaction and development.

1. Clone the project's Github repo.

```shell
git clone https://github.com/Okpainmo/deeco-2.0__smart-contracts
```

2. Install all project dependencies.

```shell
npm install
```

3. Proceed to interact with the smart-contracts using the relevant command from the 'Important Commands' list below.

## Important commands.

1. `npx hardhat node`

Creates a new hardhat node(local blockchain environment).

2. `npx hardhat compile`

Compiles all the smart contracts in the contracts directory.

3. `npx hardhat ignition deploy ./ignition/modules/<contract-ignition-module>.ts --network <network-name> --deployment-id <desired-deployment-id>`

Deploys your smart contract to the specified network(the network must have been configured in your hardhat config file).

E.g: `npx hardhat ignition deploy ./ignition/modules/Lock.ts --network localhost --deployment-id localhost-deployment`

4. `npx hardhat ignition verify <deployment-id>`

Verifies smart contracts deployed on testnets/mainnets.

E.g: `npx hardhat ignition verify sepolia-deployment`

5. `npx hardhat test`

Runs all tests. It also triggers the gas report output, hence you should be cautious about how much you run tests(with your API key on), to avoid excess cost and/or rate limiting due to too many API requests(see the gas reporter setup inside hardhat config file for more insight).

6. `npx hardhat coverage`

Checks for test coverage. Ensure to add the "solidity coverage import to your hardhat config file(`import solidity-coverage`) - already added on this template.

7. `npm run lint`

For linting Solidity(smart contract) code with solhint(see the `lint` script inside `package.json`).

## Smart Contract Architecture.

This section details the project's plan and architecture.


