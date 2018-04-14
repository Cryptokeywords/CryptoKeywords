import { Injectable } from '@angular/core';
import { ContractService } from '../../common/contract.service';
import { Web3Service } from '../../common/web3.service';
var ColorHash = require('color-hash');

@Injectable()
export class ProfileService {
    public nickname: string;
    public profile: string;

    constructor(public contractService: ContractService,
        public web3Service: Web3Service) {
    }

    public async init() {
        await this.contractService.init();
        await this.onReady();
    }

    public async onReady() {
        await this.refreshData();
    };

    public async refreshData() {
        this.nickname = await this.getNickname();
    }

    public async getNickname(): Promise<string> {
        const meta = await this.contractService.identityDeployed();
        try {
            const value = await meta.getNickname(this.contractService.account, {
                from: this.contractService.account
            });
            return value;
        } catch (e) {
            console.log(e);
            //this.contractService.setError('Error getting nickname; see log.');
        }
    }

    public async nicknameAvailable(nickname: string): Promise<boolean> {
        const meta = await this.contractService.identityDeployed();
        try {
            const value = await meta.nicknameAvailable(nickname, {
                from: this.contractService.account
            });
            return value;
        } catch (e) {
            console.log(e);
            this.contractService.setError('Error getting token; see log.');
        }
    }

    public async updateNickname(nickname: string) {
        if (nickname.length > 30) {
            nickname = nickname.substring(0, 30);
        }

        this.contractService.setStatus('Initiating transaction... (please wait)');

        let available = await this.nicknameAvailable(nickname);
        if (!available) {
            this.contractService.setError("Nickname taken.");
        } else {
            const meta = await this.contractService.identityDeployed();
            try {
                await meta.updateNickname(nickname, {
                    from: this.contractService.account
                });
                this.contractService.setStatus('Nickname saved.');
                await this.getNickname();
            } catch (e) {
                console.log(e);
                this.contractService.setError('Error updating nickname; see log.');
            }
        }
    }

    public async getProfile(): Promise<string> {
        const meta = await this.contractService.identityDeployed();
        try {
            const value = await meta.getProfile(this.contractService.account, {
                from: this.contractService.account
            });
            return value;
        } catch (e) {
            console.log(e);
            this.contractService.setError('Error getting profile; see log.');
        }
    }

    public async updateProfile(profile: string) {
        if (profile.length > 250) {
            profile = profile.substring(0, 250);
        }

        this.contractService.setStatus('Initiating transaction... (please wait)');

        const meta = await this.contractService.identityDeployed();
        try {
            await meta.updateProfile(profile, {
                from: this.contractService.account
            });
            this.contractService.setStatus('Profile saved.');
        } catch (e) {
            console.log(e);
            this.contractService.setError('Error updating profile; see log.');
        }
    }

    public async getLink(): Promise<string> {
        const meta = await this.contractService.identityDeployed();
        try {
            const value = await meta.getLink(this.contractService.account, {
                from: this.contractService.account
            });
            return value;
        } catch (e) {
            console.log(e);
            //this.contractService.setError('Error getting nickname; see log.');
        }
    }

    public async updateLink(link: string) {
        this.contractService.setStatus('Initiating transaction... (please wait)');

        const meta = await this.contractService.identityDeployed();
        try {
            await meta.updateLink(link, {
                from: this.contractService.account
            });
            this.contractService.setStatus('Link saved.');
            await this.getNickname();
        } catch (e) {
            console.log(e);
            this.contractService.setError('Error updating link; see log.');
        }
    }
}
