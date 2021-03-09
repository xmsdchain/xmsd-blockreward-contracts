# Block Rewards Contracts

## Testing and Development

Dependencies

* python3 version 3.6 or greater, python3-dev
* brownie - tested with version 1.12.0
* ganache-cli - tested with version 6.11.0
* Contracts are compiled using [Solidity], however installation of the required Solidity versions is handled by Brownie.

## Setup

To get started, first create and initialize a Python virtual environment. Next, clone the repo and install the developer dependencies:

* git clone 
* cd contracts
* pip install -r requirements.txt

Run the command:
```bash
npm install
```

It executes several intallation steps:

* install all npm dependencies
* install all python dependencies (if not installed yet) including Brownie framework
* install Brownie dependency packages (openzeppelin)
* copy these packages to the working directory (see explanation below)
* compile contracts
* generate abi artifaacts (if needed)
*  Due to the existing bug in Brownie framework you may need to install the packages manually:

```bash
npm run clone-packages
```

## Running the Tests

To run the entire suite:

```bash
brownie test
```
