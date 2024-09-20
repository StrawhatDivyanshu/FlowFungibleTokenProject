import FungibleToken from 0x01 // Importing the standard Fungible Token interface

pub contract FlowFungibleToken: FungibleToken {

    // Total supply of the token
    pub var totalSupply: UFix64

    // The Vault resource that represents users' token vaults
    pub resource Vault: FungibleToken.Vault {
        pub var balance: UFix64

        init(balance: UFix64) {
            self.balance = balance
        }

        // Withdraw function to transfer tokens from one vault to another
        pub fun withdraw(amount: UFix64): @FungibleToken.Vault {
            self.balance = self.balance - amount
            return <- create Vault(balance: amount)
        }

        // Deposit function to accept tokens into a vault
        pub fun deposit(from: @FungibleToken.Vault) {
            let vault <- from as! @Vault
            self.balance = self.balance + vault.balance
            vault.balance = 0.0
            destroy vault
        }
    }

    // Minting resource, only available to contract owner
    pub resource Minter {
        pub fun mintTokens(amount: UFix64, recipient: &FlowFungibleToken.Vault) {
            recipient.deposit(from: <- create Vault(balance: amount))
            FlowFungibleToken.totalSupply = FlowFungibleToken.totalSupply + amount
        }
    }

    // Create a new Vault resource
    pub fun createEmptyVault(): @Vault {
        return <- create Vault(balance: 0.0)
    }

    init() {
        self.totalSupply = 0.0
        let minter <- create Minter()
        self.account.save(<-minter, to: /storage/Minter)
    }
}
