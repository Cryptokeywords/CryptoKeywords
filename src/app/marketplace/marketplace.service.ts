import { Injectable } from '@angular/core';
import { ContractDataService } from '../data/contractdata.service';
import { Keyword } from '../data/keyword';

@Injectable()
export class MarketplaceService {
    tag: string;
    count: number;
    isAscending: boolean;
    tokens: number[];
    keywords: Keyword[];
    sortText: string;
    loading: string;

    constructor(private contractDataService: ContractDataService) {
        this.isAscending = false;
        this.setSortText();
    }

    public async init(tag: string) {
        await this.onReady(tag);
    }

    public async onReady(tag: string) {
        this.count = 50;
        this.tag = tag;
        this.keywords = [];
        const tokenIds = await this.contractDataService.getTokensByTag(tag);
        await this.getTokens(tokenIds);
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
            if (a.uniqueText < b.uniqueText) {
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
            if (a.uniqueText < b.uniqueText) {
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

    public async getTokens(tokenIds: string[]) {
        this.keywords = [];
        var count = 0;
        for (let tokenId of tokenIds) {
            count = count + 1;
            this.loading = "Loading keywords. Please wait... [" + count + " of " + tokenIds.length + "]"
            if ((tokenId) && (tokenId != "0")) {
                let token = await this.contractDataService.assembleKeyword(tokenId);
                this.keywords.push(token);
            }
        }

        this.loading = "";
        this.sortItems();
    }
}
