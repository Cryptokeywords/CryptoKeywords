import { Component, HostListener, NgZone } from '@angular/core';
import { ContractService } from '../../common/contract.service';
import { ProfileService } from './profile.service';

declare var window: any;

@Component({
  selector: 'app-profile',
  templateUrl: './profile.component.html'
})
export class ProfileComponent {
  public nickname: string;
  public profile: string;
  public link: string;

  constructor(public _ngZone: NgZone,
    public contractService: ContractService,
    public profileService: ProfileService) {

  }

  @HostListener('window:load')
  async windowLoaded() {
  }  

  async ngOnInit() {
    await this.profileService.init();
    await this.refresh();
  }
  
  public async refresh() {
    this.nickname = await this.profileService.getNickname();
    this.profile = await this.profileService.getProfile();
    this.link = await this.profileService.getLink();
  }

  public setNickname() {
    this.profileService.updateNickname(this.nickname);
  }

  public setProfile() {
    this.profileService.updateProfile(this.profile);
  }

  public setLink() {
    this.profileService.updateLink(this.link);
  }
}
