import { Injectable } from '@angular/core';
import { ContractService } from '../../common/contract.service';
import { Web3Service } from '../../common/web3.service';
import { ContractDataService } from '../data/contractdata.service';
import { Keyword } from '../data/keyword';

@Injectable()
export class KeywordsService {
    count: number;
    tokens: number[];
    keywords: Keyword[];
    colorHash: any;
    loading: string;

    constructor(public contractDataService: ContractDataService,
        public contractService: ContractService,
        public web3Service: Web3Service) {
    }

    public async init() {
        await this.contractService.init();
        this.web3Service.accountsObservable.subscribe(async (accounts) => {
            const keywords = await this.contractDataService.getKeywords(accounts[0]);
            await this.getTokens(keywords);
            this.contractService.setStatus("");
        });
    }

    public async getTokens(tokenIds: string[]) {
        this.keywords = [];
        var count = 0;
        this.loading = "";
        if (tokenIds.length > 0) {
            for (let tokenId of tokenIds) {
                count = count + 1;
                this.loading = "Loading keywords. Please wait... [" + count + " of " + tokenIds.length + "]"
                if ((tokenId) && (tokenId != "0")) {
                    let token = await this.contractDataService.assembleKeyword(tokenId);
                    this.keywords.push(token);
                }
            }
        }

        this.loading = "";
    }
}
