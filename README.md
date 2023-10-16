## Access Manager demo setup

This is a demo setup for the Access Manager built in [Foundry](https://book.getfoundry.sh/). It deploys the following contracts:

- AccessManager: The Access Manager contract itself.
- DAOGovernor: A DAO setup to operate with the Access Manager as its timelock.
- DAOToken: A token which minting is restricted by the Access Manager for a MINTER_ROLE.
- Owned: An Ownable contract connected to an Access Manager as its owner.
- AccessControlled: An AccessControl contract connected to an Access Manager as its DEFAULT_ADMIN_ROLE.
- RollupUpgradeable: A fake rollup contract permissioned by the AccessManager.

### Getting started

Create a copy of the `.env.example` into a fresh new `.env` file. Then make sure to fill the following values:

- Addresses: These are the holders of each role. Those marked as optional can be omitted and holder of the `ADMIN_ROLE` will be used instead.
- RPC API Keys: Fill the `API_KEY_ALCHEMY` for mainnet. Otherwise use `API_KEY_INFURA`. More detail in the [`foundry.toml`](./foundry.toml) file.
- Block explorer API Keys: Fill only the API key for the network you'll deploy on.
- Fill the `MNEMONIC` variable with a mnemonic phrase. The first derived account will be used to deploy the contracts, setup the roles and finally renounce its own role. Note this address will hold all the DAOTokens minted at first.

### Deploying

```shell
forge script script/Deploy.s.sol --broadcast --rpc-url <network>
```

### Learn more

Explore the [demo manager at the Access Manager Explorer](https://access-manager-explorer.vercel.app/explorer/mgr-0x4ee69a1703b717cb46cd12c71c6fe225f646ba1e)

### Acknowledgements

- [PaulRBerg/foundry-template](https://github.com/PaulRBerg/foundry-template/)
