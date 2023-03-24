## A Simple Voting app built on the Celo blockchain with solidity and deployed with Golang


## The Smart Contract

```solidity
    // SPDX-License-Identifier: MIT

    pragma solidity ^0.8.0;

    contract Voting {
        
        struct Candidate {
            uint256 id;
            string name;
            uint256 voteCount;
        }
        
        mapping(address => bool) public hasVoted;
        mapping(uint256 => Candidate) public candidates;
        uint256 public candidatesCount;
        
        event Voted(uint256 indexed candidateId, address indexed voter);
        
        constructor(string[] memory _candidateNames) {
            for (uint256 i = 0; i < _candidateNames.length; i++) {
                addCandidate(_candidateNames[i]);
            }
        }
        
        function addCandidate(string memory _name) private {
            candidatesCount++;
            candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
        }
        
        function vote(uint256 _candidateId) public {
            require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID.");
            require(!hasVoted[msg.sender], "You have already voted.");
            candidates[_candidateId].voteCount++;
            hasVoted[msg.sender] = true;
            emit Voted(_candidateId, msg.sender);
        }
        
        function getCandidate(uint256 _candidateId) public view returns (uint256, string memory, uint256) {
            require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID.");
            Candidate memory candidate = candidates[_candidateId];
            return (candidate.id, candidate.name, candidate.voteCount);
        }
        
        function getCandidatesCount() public view returns (uint256) {
            return candidatesCount;
        }
    }

```

## Deployment script

```go
    package main

    import (
        "context"
        "crypto/ecdsa"
        "fmt"
        "io/ioutil"
        "log"
        "math/big"


        "github.com/ethereum/go-ethereum/accounts/abi/bind"
        "github.com/ethereum/go-ethereum/common"
        "github.com/ethereum/go-ethereum/core/types"
        "github.com/ethereum/go-ethereum/crypto"
        "github.com/ethereum/go-ethereum/ethclient"
    )




    // Replace this with your own private key and Celo node URL
    const privateKey = "your-private-key"
    const nodeURL = "https://alfajores-forno.celo-testnet.org"

    func main() {
        // Connect to the Celo network
        client, err := ethclient.Dial(nodeURL)
        if err != nil {
            log.Fatalf("Failed to connect to the Celo network: %v", err)
        }
        defer client.Close()

        // Load the private key
        key, err := crypto.HexToECDSA(privateKey)
        if err != nil {
            log.Fatalf("Failed to load the private key: %v", err)
        }

        // Load the contract ABI
        abiBytes, err := ioutil.ReadFile("Voting.abi")
        if err != nil {
            log.Fatalf("Failed to read the contract ABI: %v", err)
        }
        fmt.Println(abiBytes)
        
        // Load the contract bytecode
        bytecode, err := ioutil.ReadFile("Voting.bin")
        if err != nil {
            log.Fatalf("Failed to read the contract bytecode: %v", err)
        }

        // Get the public address associated with the private key
        publicKey := key.Public().(*ecdsa.PublicKey)
        address := crypto.PubkeyToAddress(*publicKey)

        // Get the nonce associated with the address
        nonce, err := client.PendingNonceAt(context.Background(), address)
        if err != nil {
            log.Fatalf("Failed to get the nonce: %v", err)
        }

        // Get the gas price
        gasPrice, err := client.SuggestGasPrice(context.Background())
        if err != nil {
            log.Fatalf("Failed to get the gas price: %v", err)
        }

        // Create a new transaction
        tx := types.NewContractCreation(nonce, big.NewInt(0), 3000000, gasPrice, common.FromHex(string(bytecode)))

        // Sign the transaction
        signedTx, err := types.SignTx(tx, types.NewEIP155Signer(big.NewInt(44787)), key)
        if err != nil {
            log.Fatalf("Failed to sign the transaction: %v", err)
        }

        // Broadcast the transaction
        err = client.SendTransaction(context.Background(), signedTx)
        if err != nil {
            log.Fatalf("Failed to broadcast the transaction: %v", err)
        }

        // Wait for the transaction receipt
        receipt, err := bind.WaitMined(context.Background(), client, signedTx)
        if err != nil {
            log.Fatalf("Failed to get the transaction receipt: %v", err)
        }

        // Print the contract address
        fmt.Printf("Smart contract deployed at address: %s\n", receipt.ContractAddress.Hex())
    }

```