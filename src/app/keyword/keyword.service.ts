import { Injectable } from '@angular/core';
import { ContractService } from '../../common/contract.service';
import { Web3Service } from '../../common/web3.service';
import { ContractDataService } from '../data/contractdata.service';
import { Keyword } from '../data/keyword';
import { Metadata } from '../data/metadata';

@Injectable()
export class KeywordService {
    owned: boolean;
    sub: any;
    colorHash: any;

    constructor(public contractDataService: ContractDataService,
        public contractService: ContractService,
        public web3Service: Web3Service) {
    }

    public async init(tokenId: string) {
        await this.contractService.init();
        this.web3Service.accountsObservable.subscribe(async (accounts) => {
            this.owned = await this.contractDataService.isOwned(tokenId);
        });
    }
}
