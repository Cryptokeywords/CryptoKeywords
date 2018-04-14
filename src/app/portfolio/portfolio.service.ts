import { Injectable } from '@angular/core';
import { ContractService } from '../../common/contract.service';
import { Web3Service } from '../../common/web3.service';
import { ContractDataService } from '../data/contractdata.service';
import { Keyword } from '../data/keyword';
import { Metadata } from '../data/metadata';
var ColorHash = require('color-hash');

@Injectable()
export class PortfolioService {
    isAscending: boolean;
    keywords: Keyword[];
    sortText: string;
    loading: string;

    constructor(public contractDataService: ContractDataService,
        public contractService: ContractService,
        public web3Service: Web3Service) {
    }

    public async init(address: string) {
        await this.contractService.init();
        await this.onReady(address);
    }

    public async onReady(address: string) {
        const tokenIds = await this.contractDataService.tokensOfOwner(address);
        this.assembleKeywords(tokenIds);
        this.contractService.setStatus("");
        this.setSortText();
    };

    public async changeOrder() {
        this.isAscending = !this.isAscending;
        this.sortItems();
        this.setSortText();
    }

    public sortItems() {
        if (this.isAscending) {
            this.keywords = this.keywords.sort(this.compareAsc);
        } else {
            this.keywords = this.keywords.sort(this.compareDesc);
        }
    }

    public compareAsc(a: Keyword, b: Keyword): number {
        let result: number;
        if (a.currentPrice < b.currentPrice) {
            return -1;
        }
        if (a.currentPrice > b.currentPrice) {
            return 1;
        }
        if (a.currentPrice == b.currentPrice) {
            if (a.tokenId < b.tokenId) {
                return 1;
            } else {
                return -1;
            }
        }
    }

    public compareDesc(a: Keyword, b: Keyword): number {
        let result: number;
        if (a.currentPrice < b.currentPrice) {
            return 1;
        }
        if (a.currentPrice > b.currentPrice) {
            return -1;
        }
        if (a.currentPrice == b.currentPrice) {
            if (a.tokenId < b.tokenId) {
                return -1;
            } else {
                return 1;
            }
        }
    }

    public setSortText() {
        if (this.isAscending) {
            this.sortText = "Cheapest first";
        } else {
            this.sortText = "Most expensive first";
        }
    }

    public async assembleKeywords(tokenIds: string[]) {
        this.keywords = [];
        var count = 0;
        this.loading = "";
        for (let tokenId of tokenIds) {
            count = count + 1;
            if ((tokenId) && (tokenId != "0")) {
                this.loading = "Loading keywords. Please wait... [" + count + " of " + tokenIds.length + "]"
                let token = await this.contractDataService.assembleKeyword(tokenId);
                this.keywords.push(token);
            }
        }

        this.sortItems();
        this.loading = "";
    }
}
