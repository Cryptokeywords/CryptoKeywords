import {Injectable} from '@angular/core';
import Web3 from 'web3';
import {default as contract} from 'truffle-contract';
import {Subject} from 'rxjs/Rx';
import * as toastr from 'toastr';

declare let window: any;

@Injectable()
export class Web3Service {
  public web3: Web3;
  public accounts: string[];
  public MetaCoin: any;
  public accountsObservable = new Subject<string[]>();
  public isNotReady: boolean;
  public connectionStatus: string;

  constructor() {
    window.addEventListener('load', (event) => {
      this.bootstrapWeb3();
      this.isNotReady = false;
      this.connectionStatus = "";
      toastr.options = {
        preventDuplicates: true,
        timeOut: 0,
        extendedTimeOut: 0,
        closeButton: true
      };
    });
  }

  public appProvider(): any {
    // Checking if Web3 has been injected by the browser (Mist/MetaMask)
    if (typeof window.web3 !== 'undefined') {
      // Use Mist/MetaMask's provider
      this.isNotReady = false;
      this.connectionStatus = "";
      return window.web3.currentProvider;
    } else {
      this.isNotReady = true;
      this.connectionStatus = "No web3 client. Please use MetaMask (requires Chrome or Firefox) or Mist.";
      toastr.options = {
        preventDuplicates: true,
        timeOut: 0,
        extendedTimeOut: 0,
        closeButton: true
      };
      toastr.warning(this.connectionStatus);

      // Hack to provide backwards compatibility for Truffle, which uses web3js 0.20.x
      Web3.providers.HttpProvider.prototype.sendAsync = Web3.providers.HttpProvider.prototype.send;
      // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
      return new Web3.providers.HttpProvider('http://localhost:8545');
    }
  }

  public bootstrapWeb3() {
    // Checking if Web3 has been injected by the browser (Mist/MetaMask)
    if (typeof window.web3 !== 'undefined') {
      // Use Mist/MetaMask's provider
      this.web3 = new Web3(window.web3.currentProvider);
      this.isNotReady = false;
      this.connectionStatus = "";
    } else {
      console.log('No web3? You should consider trying MetaMask!');
      this.isNotReady = true;
      this.connectionStatus = "No web3 client. Please use MetaMask (requires Chrome or Firefox) or Mist.";
      toastr.options = {
        preventDuplicates: true,
        timeOut: 0,
        extendedTimeOut: 0,
        closeButton: true
      };
      toastr.warning(this.connectionStatus);

      // Hack to provide backwards compatibility for Truffle, which uses web3js 0.20.x
      Web3.providers.HttpProvider.prototype.sendAsync = Web3.providers.HttpProvider.prototype.send;
      // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
      this.web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));
    }

    setInterval(() => this.refreshAccounts(), 100);
  }

  public async artifactsToContract(artifacts) {
    if (!this.web3) {
      const delay = new Promise(resolve => setTimeout(resolve, 100));
      await delay;
      return await this.artifactsToContract(artifacts);
    }

    const contractAbstraction = contract(artifacts);
    contractAbstraction.setProvider(this.appProvider);
    return contractAbstraction;
  }

  public refreshAccounts() {
    this.web3.eth.getAccounts((err, accs) => {
      console.log('Refreshing accounts');
      if (err != null) {
        console.warn('There was an error fetching your accounts.');
        this.isNotReady = true;
        this.connectionStatus = "Unable to fetch accounts.";
        toastr.options = {
          preventDuplicates: true,
          timeOut: 0,
          extendedTimeOut: 0,
          closeButton: true
        };
        toastr.warning(this.connectionStatus);
        return;
      }

      // Get the initial account balance so it can be displayed.
      if (accs.length === 0) {
        console.warn('Couldn\'t get any accounts! Make sure your Ethereum client is configured correctly.');
        this.isNotReady = true;
        this.connectionStatus = "Unable to get any accounts. Please make sure your Ethereum client (MetaMask or Mist) is configured correctly.";
        toastr.options = {
          preventDuplicates: true,
          timeOut: 0,
          extendedTimeOut: 0,
          closeButton: true
        };
        toastr.warning(this.connectionStatus);
        return;
      }

      if (!this.accounts || this.accounts.length !== accs.length || this.accounts[0] !== accs[0]) {
        console.log('Observed new accounts');

        this.accountsObservable.next(accs);
        this.accounts = accs;

        this.isNotReady = false;
        this.connectionStatus = "";
      }
    });
  }
}
