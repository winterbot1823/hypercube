
### Wallet CLI

The general form is:
```
$ hypercube-wallet [common-options] [command] [command-specific options]
```
`common-options` include:
* `--fee xyz` - Transaction fee (0 by default)
* `--output file` - Write the raw Transaction to a file instead of sending it

`command` variants:
* `pay`
* `cancel`
* `send-signature`
* `send-timestamp`

#### Unconditional Immediate Transfer
```sh
// Command
$ hypercube-wallet pay <PUBKEY> 123

// Return
<TX_SIGNATURE>
```

#### Post-Dated Transfer
```sh
// Command
$ hypercube-wallet pay <PUBKEY> 123 \
    --after 2018-12-24T23:59:00 --require-timestamp-from <PUBKEY>

// Return
{signature: <TX_SIGNATURE>, processId: <PROCESS_ID>}
```
*`require-timestamp-from` is optional. If not provided, the transaction will expect a timestamp signed by this wallet's secret key*

#### Authorized Transfer
A third party must send a signature to unlock the tokens.
```sh
// Command
$ hypercube-wallet pay <PUBKEY> 123 \
    --require-signature-from <PUBKEY>

// Return
{signature: <TX_SIGNATURE>, processId: <PROCESS_ID>}
```

#### Post-Dated and Authorized Transfer
```sh
// Command
$ hypercube-wallet pay <PUBKEY> 123 \
    --after 2018-12-24T23:59 --require-timestamp-from <PUBKEY> \
    --require-signature-from <PUBKEY>

// Return
{signature: <TX_SIGNATURE>, processId: <PROCESS_ID>}
```

#### Multiple Witnesses
```sh
// Command
$ hypercube-wallet pay <PUBKEY> 123 \
    --require-signature-from <PUBKEY> \
    --require-signature-from <PUBKEY>

// Return
{signature: <TX_SIGNATURE>, processId: <PROCESS_ID>}
```

#### Cancelable Transfer
```sh
// Command
$ hypercube-wallet pay <PUBKEY> 123 \
    --require-signature-from <PUBKEY> \
    --cancelable

// Return
{signature: <TX_SIGNATURE>, processId: <PROCESS_ID>}
```

#### Cancel Transfer
```sh
// Command
$ hypercube-wallet cancel <PROCESS_ID>

// Return
<TX_SIGNATURE>
```

#### Send Signature
```sh
// Command
$ hypercube-wallet send-signature <PUBKEY> <PROCESS_ID>

// Return
<TX_SIGNATURE>
```

#### Indicate Elapsed Time

Use the current system time:
```sh
// Command
$ hypercube-wallet send-timestamp <PUBKEY> <PROCESS_ID>

// Return
<TX_SIGNATURE>
```

Or specify some other arbitrary timestamp:
```sh
// Command
$ hypercube-wallet send-timestamp <PUBKEY> <PROCESS_ID> --date 2018-12-24T23:59:00

// Return
<TX_SIGNATURE>
```


## Javascript hypercube-web3.js Interface

*TBD, but will look similar to what the Wallet CLI offers wrapped up in a
Javacsript object*
