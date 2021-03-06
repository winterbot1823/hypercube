# Storage

The goal of this RFC is to define a protocol for storing a very large ledger over a p2p network that is verified by hypercube validators.  At full capacity on a 1gbps network hypercube will generate 4 petabytes of data per year.  To prevent the network from centralizing around full nodes that have to store the full data set this protocol proposes a way for mining nodes to provide storage capacity for pieces of the network.

# Version 

version 0.1

# Background

The basic idea to Proof of Replication is encrypting a dataset with a public symmetric key using CBC encryption, then hash the encrypted dataset. The main problem with the naive approach is that a dishonest storage node can stream the encryption and delete the data as its hashed. The simple solution is to force the hash to be done on the reverse of the encryption, or perhaps with a random order. This ensures that all the data is present during the generation of the proof and it also requires the validator to have the entirety of the encrypted data present for verification of every proof of every identity. So the space required to validate is `(Number of Proofs)*(data size)`

# Optimization with PoH 

Our improvement on this approach is to randomly sample the encrypted blocks faster than it takes to encrypt, and record the hash of those samples into the PoH ledger. Thus the blocks stay in the exact same order for every PoRep and verification can stream the data and verify all the proofs in a single batch. This way we can verify multiple proofs concurrently, each one on its own CUDA core. With the current generation of graphics cards our network can support up to 14k replication identities or symmetric keys. The total space required for verification is `(2 CBC blocks) * (Number of Identities)`, with core count of equal to (Number of Identities). A CBC block is expected to be 1MB in size.

# Network

Validators for PoRep are the same validators that are verifying transactions. They have some stake that they have put up as collateral that ensures that their work is honest. If you can prove that a validator verified a fake PoRep, then the validators stake can be slashed.

Replicators are specialized thin clients. They download a part of the ledger and store it, and provide PoReps of storing the ledger. For each verified PoRep replicators earn a reward of xpz from the mining pool.

# Constraints

We have the following constraints:
* At most 14k  replication identities can be used, because thats how many CUDA cores we can fit in a $5k box at the moment.
* Verification requires generating the CBC blocks. That requires space of 2 blocks per identity, and 1 CUDA core per identity for the same dataset. So as many identities at once should be batched with as many proofs for those identities verified concurrently for the same dataset.

# Validation and Replication Protocol

1. Network sets the replication target number, lets say 1k. 1k PoRep identities are created from signatures of a PoH hash. So they are tied to a specific PoH hash. It doesn't matter who creates them, or simply the last 1k validation signatures we saw for the ledger at that count. This maybe just the initial batch of identities, because we want to stagger identity rotation.
2. Any client can use any of these identities to create PoRep proofs. Replicator identities are the CBC encryption keys.
3. Periodically at a specific PoH count, replicator that want to create PoRep proofs sign the PoH hash at that count. That signature is the seed used to pick the block and identity to replicate. A block is 1TB of ledger.
4. Periodically at a specific PoH count, replicator submits PoRep proofs for their selected block. A signature of the PoH hash at that count is the seed used to sample the 1TB encrypted block, and hash it. This is done faster than it takes to encrypt the 1TB block with the original identity.
5. Replicators must submit some number of fake proofs, which they can prove to be fake by providing the seed for the hash result.
6. Periodically at a specific PoH count, validators sign the hash and use the signature to select the 1TB block that they need to validate. They batch all the identities and proofs and submit approval for all the verified ones.
7. After #6, replicator client submit the proofs of fake proofs.

For any random seed, we force everyone to use a signature that is derived from a PoH hash. Everyone must use the same count, so the same PoH hash is signed by every participant. The signatures are then each cryptographically tied to the keypair, which prevents a leader from grinding on the resulting value for more than 1 identity.

We need to stagger the rotation of the identity keys. Once this gets going, the next identity could be generated by hashing itself with a PoH hash, or via some other process based on the validation signatures.

Since there are many more client identities then encryption identities, we need to split the reward for multiple clients, and prevent Sybil attacks from generating many clients to acquire the same block of data. To remain BFT we want to avoid a single human entity from storing all the replications of a single chunk of the ledger.

Our solution to this is to force the clients to continue using the same identity. If the first round is used to acquire the same block for many client identities, the second round for the same client identities will force a redistribution of the signatures, and therefore PoRep identities and blocks. Thus to get a reward for storage clients need to store the first block for free and the network can reward long lived client identities more than new ones.

# Notes

* We can reduce the costs of verification of PoRep by using PoH, and actually make it feasible to verify a large number of proofs for a global dataset.
* We can eliminate grinding by forcing everyone to sign the same PoH hash and use the signatures as the seed
* The game between validators and replicators is over random blocks and random encryption identities and random data samples. The goal of randomization is to prevent colluding groups from having overlap on data or validation.
* Replicator clients fish for lazy validators by submitting fake proofs that they can prove are fake.
* Replication identities are just symmetric encryption keys, the number of them on the network is our storage replication target. Many more client identities can exist than replicator identities, so unlimited number of clients can provide proofs of the same replicator identity.
* To defend against Sybil client identities that try to store the same block we force the clients to store for multiple rounds before receiving a reward.
