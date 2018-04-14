import { Injectable } from '@angular/core';
import { Web3Service } from '../../common/web3.service';
import { ContractService } from '../../common/contract.service';
import { Keyword } from './keyword';
import { Metadata } from './metadata';
var ColorHash = require('color-hash');

@Injectable()
export class ContractDataService {
    colorHash: any;
    registrarAddress: string = "0x88910F6f5F0B8B1AC87b855D8f640ceEe30F5836";

    constructor(public contractService: ContractService,
        public web3Service: Web3Service) {
        var customHash = function(str) {
            var hash = 0;
            for(var i = 0; i < str.length; i++) {
                hash += str.charCodeAt(i);
            }
            return hash;
        };
        this.colorHash = new ColorHash({hash: customHash, lightness: 0.9});
    }

    public async assembleKeyword(tokenId: string): Promise<Keyword> {
        let keyword: Keyword;
        keyword = new Keyword();
        keyword.tokenId = tokenId;

        const tokenValues = await this.getToken(tokenId);
        keyword.mintTime = tokenValues[0];
        keyword.uniqueText = await this.getUniqueText(tokenId);

        // SET PRICE / FEE VALUES
        keyword.currentPrice = this.web3Service.web3.fromWei(tokenValues[1], 'ether');
        keyword.payAmount = keyword.currentPrice;
        let roundedPrice = Math.round(Number(keyword.currentPrice) * 10000) / 10000;
        keyword.roundedPrice = roundedPrice.toString();
        keyword.currentPriceWei = tokenValues[1];
        keyword.nextPrice = this.nextPrice(keyword.currentPrice);
        let roundedNext = Math.round(Number(keyword.nextPrice) * 100000) / 100000;
        keyword.nextPrice = roundedNext.toString();
        let devFee: number = +keyword.nextPrice * this.getDevFee(+keyword.nextPrice);
        let registrarFee: number = +keyword.nextPrice * this.getRegistrarFee();
        let keywordFee: number = +keyword.nextPrice * this.getKeywordFee(keyword.uniqueText);
        keyword.netReceive = String(+keyword.nextPrice - (devFee + registrarFee + keywordFee));
        let roundedReceive = Math.round(Number(keyword.netReceive) * 100000) / 100000;
        keyword.netReceive = roundedReceive.toString();

        keyword.trades = tokenValues[2];
        keyword.colorHash = this.colorHash.hex(keyword.uniqueText);

        // OWNERSHIP
        keyword.owner = await this.getOwner(tokenId);
        keyword.nickname = await this.getNickname(keyword.owner);

        // CONTENT / METADATA
        keyword.metadataString = await this.getMetadata(tokenId, keyword.owner);
        keyword.flagged = await this.getFlagged(keyword.metadataString);
        if (keyword.metadataString) {
            keyword.metadata = JSON.parse(keyword.metadataString);
        }
        keyword.metadataAvailable = true;
        if (!keyword.metadata) {
            keyword.metadataAvailable = false;
        } else {
            if (!keyword.metadata.type) {
                keyword.metadataAvailable = false;
            } else {
                if (keyword.metadata.type == 'url') {
                    if (!keyword.metadata.url) {
                        keyword.metadataAvailable = false;
                    }
                }
                if (keyword.metadata.type == 'youtube') {
                    if (!keyword.metadata.youtube) {
                        keyword.metadataAvailable = false;
                    }
                }
            }
        }

        this.contractService.setStatus("");

        return keyword;
    }

    // CORE

    public async getToken(tokenId: string): Promise<any> {
        const metaCore = await this.contractService.coreDeployed();
        try {
            const tokenValue = await metaCore.getToken(
                tokenId, {
                from: this.contractService.account
            });

            return tokenValue;
        } catch (e) {
            console.log(e);
            this.contractService.setError('Error getting item from core; see log.');
        }
    }

    public async getUniqueText(tokenId: string): Promise<string> {
        const metaCore = await this.contractService.coreDeployed();
        try {
            const value = await metaCore.getUniqueText(
                tokenId, {
                from: this.contractService.account
            });

            return value;
        } catch (e) {
            console.log(e);
            this.contractService.setError('Error getting owner; see log.');
        }
    }

    // PRICING / FEES

    public nextPrice(currentPrice: any): any {
        if (currentPrice < 0.05) {
            return currentPrice * 2;
        } 
        if (currentPrice < 0.5) {
            return currentPrice * 1.35;
        } 
        if (currentPrice < 2) {
            return currentPrice * 1.25;
        }
        if (currentPrice < 5) {
            return currentPrice * 1.17;
        }
        if (currentPrice >= 5) {
            return currentPrice * 1.15;
        }

        return currentPrice * 1.15;
    }

    public getDevFee(nextPrice: any): number {
        if (nextPrice < 0.05) {
            return 0.05;
        } 
        if (nextPrice < 0.5) {
            return 0.04;
        } 
        if (nextPrice < 2) {
            return 0.03;
        }
        if (nextPrice < 5) {
            return 0.03;
        }
        if (nextPrice >= 5) {
            return 0.02;
        }
    }

    public getRegistrarFee(): number {
        return 0.01;
    }

    public getKeywordFee(keyword: string): number {
        var keywords = keyword.split(' ');
        if (keywords.length == 1) {
            return 0;
        }
        if (keywords.length == 2) {
            return 0.02;
        }
        if (keywords.length == 3) {
            return 0.03;
        }

        if (keywords.length >= 4) {
            return 0.04;
        }
    }

    // ERC721

    public async isOwned(tokenId: string): Promise<boolean> {
        const meta = await this.contractService.erc721Deployed();
        try {
            const value = await meta.isOwned(tokenId, {
                from: this.contractService.account
            });

            return value;
        } catch (e) {
            console.log(e);
            this.contractService.setError('Error getting is owned; see log.');
        }
    }

    public async getOwner(tokenId: string): Promise<string> {
        const metaCore = await this.contractService.erc721Deployed();
        try {
            const value = await metaCore.ownerOf(
                tokenId, {
                from: this.contractService.account
            });

            return value;
        } catch (e) {
            console.log(e);
            this.contractService.setError('Error getting owner; see log.');
        }
    }

    public async tokensOfOwner(ownerAddress: string): Promise<string[]> {
        const meta = await this.contractService.erc721Deployed();
        try {
            const value = await meta.tokensOfOwner(ownerAddress, {
                from: this.contractService.account
            });

            return value;
        } catch (e) {
            console.log(e);
            this.contractService.setError('Error getting tokens of owner; see log.');
        }
    }

    public async getKeywords(account: any): Promise<string[]> {
        const meta = await this.contractService.erc721Deployed();
        try {
            const value = await meta.myTokens({
                from: account
            });
            return value;
        } catch (e) {
            console.log(e);
            this.contractService.setError('Error getting tokens of owner; see log.');
        }
    }

    // MINTING

    public async buy(tokenId: string, price: string) {
        let priceInWei = this.web3Service.web3.toWei(price, 'ether');
        const meta = await this.contractService.mintingDeployed();
        try {
            meta.buy(tokenId,
                this.registrarAddress, {
                from: this.contractService.account,
                value: priceInWei
            })
            .then(function() {
                window.location.href = '/keywords';
            });
            this.contractService.setStatus('Thank you for buying. Please wait...');
        } catch (e) {
            console.log(e);
            this.contractService.setError('Buy cancelled or error encountered.');
        }
    }

    // CONTENT

    public async getMetadata(tokenId: string, owner: string): Promise<string> {
        const metaCore = await this.contractService.contentDeployed();
        try {
            const value = await metaCore.getMetadata(
                tokenId, 
                owner, {
                from: this.contractService.account
            });
            
            return value;
        } catch (e) {
            console.log(e);
            this.contractService.setError('Error getting metadata; see log.');
        }            
    }

    public async setMetadata(tokenId: string, metadata: Metadata) {
        const meta = await this.contractService.contentDeployed();
        try {
            var metadataString: string = JSON.stringify(metadata);
            await meta.setMetadata(tokenId, metadataString, {
                from: this.contractService.account
            });
            this.contractService.setStatus('Content has been updated.');
            await this.getToken(tokenId);
            window.location.reload();
        } catch (e) {
            console.log(e);
            this.contractService.setError('Error encountered. Sorry for the inconvenience.');
        }
    }

    // IDENTITY

    public async getNickname(owner: string): Promise<string> {
        const meta = await this.contractService.identityDeployed();
        try {
            const value = await meta.getNickname(
                owner, {
                from: this.contractService.account
            });

            if (value) {
                return value;
            } else {
                return owner.substr(owner.length - 8);
            }
        } catch (e) {
            console.log(e);
            this.contractService.setError('Error getting nickname; see log.');
        }
    }

    public async getProfile(address: string): Promise<string> {
        const meta = await this.contractService.identityDeployed();
        try {
            const value = await meta.getProfile(address, {
                from: this.contractService.account
            });
            return value;
        } catch (e) {
            console.log(e);
            this.contractService.setError('Error getting profile; see log.');
        }
    }

    public async getLink(address: string): Promise<string> {
        const meta = await this.contractService.identityDeployed();
        try {
            const value = await meta.getLink(address, {
                from: this.contractService.account
            });
            return value;
        } catch (e) {
            console.log(e);
            //this.contractService.setError('Error getting nickname; see log.');
        }
    }

    // TAGS

    public async getTokensByTag(tag: string): Promise<string[]> {
        if (!tag) {
            tag = "cryptos";
        }
        const meta = await this.contractService.tagsDeployed();
        try {
            const value = await meta.getTokensByTag(
                tag, {
                from: this.contractService.account
            });
            return value;
        } catch (e) {
            console.log(e);
            this.contractService.setError('Error getting tokens by trade; see log.');
        }
    }

    // FLAGS
    
    public async flagContent(metadata: string) {
        this.contractService.setStatus('Initiating transaction... (please wait)');
        try {
            const meta = await this.contractService.flagsDeployed();
            await meta.setUserFlagsTrue(metadata,
                "1", {
                from: this.contractService.account
            });
            this.contractService.setStatus('Transaction complete!');
        } catch (e) {
            console.log(e);
            this.contractService.setError('Error setting user flags true; see log.');
        }
    }

    public async getFlagged(metadata: string): Promise<boolean> {
        const meta = await this.contractService.flagsDeployed();
        try {
            const value = await meta.getAdminFlagsA.call(metadata, {
                from: this.contractService.account
            });
            return value[0];
        } catch (e) {
            console.log(e);
            this.contractService.setError('Error getting admin flags A; see log.');
        }
    }
}