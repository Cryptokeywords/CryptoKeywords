import {Injectable} from '@angular/core';
import {Subject} from 'rxjs/Rx';
import {Web3Service} from './web3.service';
import * as toastr from 'toastr';
const contract = require('truffle-contract');
const friendArtifacts = require('../../build/contracts/FriendContract.json');
const coreArtifacts = require('../../build/contracts/TokenCore.json');
const indexArtifacts = require('../../build/contracts/TokenIndex.json');
const mintingArtifacts = require('../../build/contracts/TokenMinting.json');
const erc721Artifacts = require('../../build/contracts/TokenERC721.json');
const identityArtifacts = require('../../build/contracts/TokenIdentity.json');
const contentArtifacts = require('../../build/contracts/TokenContent.json');
const tagsArtifacts = require('../../build/contracts/TokenTags.json');
const flagsArtifacts = require('../../build/contracts/TokenFlags.json');

@Injectable()
export class ContractService {
    public account: any;
    public accounts: any;
    public web3: any;
    public error: string;
    public status: string;

    public FriendContract = contract(friendArtifacts);
    public TokenCore = contract(coreArtifacts);
    public TokenIndex = contract(indexArtifacts);
    public TokenMinting = contract(mintingArtifacts);
    public TokenERC721 = contract(erc721Artifacts);
    public TokenIdentity = contract(identityArtifacts);
    public TokenContent = contract(contentArtifacts);
    public TokenTags = contract(tagsArtifacts);
    public TokenFlags = contract(flagsArtifacts);

    constructor(public web3Service: Web3Service) {
        toastr.options = {
            preventDuplicates: true,
            timeOut: 0,
            extendedTimeOut: 0,
            closeButton: true
          };    
        console.log('Constructor: ' + web3Service);
    }

    public async init() {
        this.watchAccount();
        this.prepareContracts();
    }

    public async prepareContracts() {
        const friendAbstraction = await this.web3Service.artifactsToContract(friendArtifacts);
        this.FriendContract = friendAbstraction;
        const coreAbstraction = await this.web3Service.artifactsToContract(coreArtifacts);
        this.TokenCore = coreAbstraction;
        const indexAbstraction = await this.web3Service.artifactsToContract(indexArtifacts);
        this.TokenIndex = indexAbstraction;
        const mintingAbstraction = await this.web3Service.artifactsToContract(mintingArtifacts);
        this.TokenMinting = mintingAbstraction;
        const erc721Abstraction = await this.web3Service.artifactsToContract(erc721Artifacts);
        this.TokenERC721 = erc721Abstraction;
        const identityAbstraction = await this.web3Service.artifactsToContract(identityArtifacts);
        this.TokenIdentity = identityAbstraction;
        const contentAbstraction = await this.web3Service.artifactsToContract(contentArtifacts);
        this.TokenContent = contentAbstraction;
        const tagsAbstraction = await this.web3Service.artifactsToContract(tagsArtifacts);
        this.TokenTags = tagsAbstraction;
        const flagsAbstraction = await this.web3Service.artifactsToContract(flagsArtifacts);
        this.TokenFlags = flagsAbstraction;
    }

    public watchAccount() {
        this.web3Service.accountsObservable.subscribe((accounts) => {
            this.accounts = accounts;
            this.account = accounts[0];
        });
    }

    public subscribeWatchAccount(callback: any) {
        this.web3Service.accountsObservable.subscribe((accounts) => {
            callback;
        });
    }

    public friendDeployed() {
        this.FriendContract.setProvider(this.web3Service.appProvider());
        return this.FriendContract.deployed();
    }

    public coreDeployed() {
        this.TokenCore.setProvider(this.web3Service.appProvider());
        return this.TokenCore.deployed();
    }

    public indexDeployed() {
        this.TokenIndex.setProvider(this.web3Service.appProvider());
        return this.TokenIndex.deployed();
    }

    public mintingDeployed() {
        this.TokenMinting.setProvider(this.web3Service.appProvider());
        return this.TokenMinting.deployed();
    }

    public erc721Deployed() {
        this.TokenERC721.setProvider(this.web3Service.appProvider());
        return this.TokenERC721.deployed();
    }

    public identityDeployed() {
        this.TokenIdentity.setProvider(this.web3Service.appProvider());
        return this.TokenIdentity.deployed();
    }

    public contentDeployed() {
        this.TokenContent.setProvider(this.web3Service.appProvider());
        return this.TokenContent.deployed();
    }

    public tagsDeployed() {
        this.TokenTags.setProvider(this.web3Service.appProvider());
        return this.TokenTags.deployed();
    }

    public flagsDeployed() {
        this.TokenFlags.setProvider(this.web3Service.appProvider());
        return this.TokenFlags.deployed();
    }

    public setStatus(message: string) {
        this.status = message;
        this.error = "";
        if (message) {
            toastr.options = {
                preventDuplicates: true,
                timeOut: 0,
                extendedTimeOut: 0,
                closeButton: true
              };
            toastr.success(message);
        }
    };

    public setError(message: string) {
        this.error = message;
        this.status = "";
        if (message) {
            toastr.options = {
                preventDuplicates: true,
                timeOut: 0,
                extendedTimeOut: 0,
                closeButton: true
              };
            toastr.error(message);
        }
    };
}
