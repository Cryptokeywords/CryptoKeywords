import { Component, HostListener, NgZone } from '@angular/core';
import { ContractService } from '../../common/contract.service';
import { KeywordsService } from './keywords.service';

declare var window: any;

@Component({
  selector: 'app-keywords',
  templateUrl: './keywords.component.html'
})
export class KeywordsComponent {
  constructor(public _ngZone: NgZone,
    public contractService: ContractService,
    public keywordsService: KeywordsService) {

  }

  @HostListener('window:load')
  async windowLoaded() {
    await this.keywordsService.init();
  }  
}
