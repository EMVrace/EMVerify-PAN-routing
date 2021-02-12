# Tamarin

This repository contains a model of the **EMV contactless protocol** specified in [Tamarin](https://tamarin-prover.github.io/). This is an extension of the model at https://github.com/EMVrace/EMVerify, which is the complementary material of the IEEE S&P'21 paper titled *The EMV Standard: Break, Fix, Verify*. As such, much of the content of this repository is a copy from the original.

To see the actual differences between the original model and this extension, browse the diff on `Contactless.spthy` for [this commit](https://github.com/tr756gevff52131/repo/commit/69b374b3c674b71852ebe3c4bea066fd75fc01fd).

## Folder layout

* [`Contactless.spthy`](./Contactless.spthy) is the (generic) model of the EMV contactless protocol.
* [`Makefile`](./Makefile) is the GNU script to generate the target models and run the Tamarin analysis of them.
* `*.oracle` are the proof-support oracles.
* [models-n-proofs](./models-n-proofs/) contains the auto-generated target models (`.spthy`) and their proofs (`.proof`).
* [`results.html`](./results.html) shows the analysis results in HTML format.
* [tools](./tools/) contains useful scripts:
	* [`collect`](./tools/collect) is the Python script that summarizes the proofs in an human-readable HTML file. It also generates latex code of the summary table.
	* [`decomment`](./tools/decomment) is the Python script that prints a comment-free copy of the input model.

## Usage

From the generic model, the Makefile generates *target models*. These are models that are composed of one generic model in addition to extra rules that produce the `Commit` facts, which are used for the (in)validation of the security properties. A target model is generated and then analyzed with Tamarin, all by using `make` with the appropriate variable instances.

Further details on the variables and usage of them can be found in our submission file and in [https://github.com/EMVrace/EMVerify](https://github.com/EMVrace/EMVerify). The following are two variables we have added to verify countermeasures:

* `softfix`: if set to `Yes`, we restrict the analysis only to online-authorized transactions where DDA authentication was performed if the terminal ran the Visa kernel. This are the fixes to the PIN bypass on Visa, proposed in *The EMV Standard: Break, Fix, Verify*.
* `hardfix`: if set to `Yes`, we restrict the analysis only to online-authorized transactions where DDA or CDA authentication was performed. Also, here we have modified the SDAD input to include the AID. These are the countermeasures that we have proposed in our submission.

## Full-scale analysis

We have split our analysis of the **32** target models into two groups:

1. `Mastercard_<auth>_<CVM>_<value>[_PaynetPAN]`: used for the analysis of accepted transactions where, from the committing agent's perspective:
	* the card was a Mastercard,
	* the card's AIP indicated that the highest ODA method the card supports is `<auth>` (valid options are `SDA`, `DDA`, and `CDA`),
	* if the committing agent is the terminal, then the card's highest CVM supported was `<CVM>` (valid options are `NoPIN` and `OnlinePIN`),
	* the value of the transaction amount was `<value>` (valid options are `Low` and `High`, which indicate below and above the CVM-required limit, respectively), and
	* if `_PaynetPAN` is present, then the terminal routed the transaction to the payment network determined by the `PAN`; otherwise the terminal routed the transaction to the Mastercard payment network.
1. `Visa_<auth>_<value>[_PaynetPAN]`: used for the analysis of accepted transactions where, from the committing agent's perspective:
	* the card is a Visa,
	* the card's AIP indicated the processing mode `<auth>` (valid options are `EMV` and `DDA`),
	* the value of the transaction amount was `<value>` (valid options are `Low` and `High`, which indicate below and above the CVM-required limit, respectively), and
	* if `_PaynetPAN` is present, then the terminal routed the transaction to the payment network determined by the `PAN`; otherwise the terminal routed the transaction to the Visa payment network.

All proofs were constructed using Tamarin version 1.7.0 (git revision: 2884fce8c40e3e5bdb87526214652696e089326d, branch: develop) on a computing server running Ubuntu 16.04.3 with two Intel(R) Xeon(R) E5-2650 v4 @ 2.20GHz CPUs (with 12 cores each) and 256GB of RAM. Here we used 10 threads and at most 20GB of RAM per target model.

## Verified Countermeasures

**The countermeasures to the PIN bypass on Visa**, proposed in *The EMV Standard: Break, Fix, Verify*, are the following:
1. The terminal must always have the card supply the SDAD.
1. The terminal must always verify the SDAD.

To produce the security proof for these fixes, run: 
```shell
make paynet=PAN softfix=Yes
```
which generates the model file `Contactless_SoftFix.spthy` and the proof file `Contactless_SoftFix.proof`.

**Our countermeasures to the brand mixup attack** are the following:

1. All transactions must have the card supply the SDAD and the terminal verify it.
1. The selected AID must be part of the input to the SDAD.

To produce the security proof for these fixes, run: 
```shell
make paynet=PAN hardfix=Yes
```
which generates the model file `Contactless_HardFix.spthy` and the proof file `Contactless_HardFix.proof`.
