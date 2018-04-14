import { Component, OnInit, HostListener, NgZone } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';
import { ContractService } from '../../common/contract.service';
import { ContractDataService } from '../data/contractdata.service';
import { MarketplaceService } from './marketplace.service';

declare var window: any;

@Component({
  selector: 'app-marketplace',
  templateUrl: './marketplace.component.html'
})
export class MarketplaceComponent implements OnInit {  
  tag: string;
  tokenId: string;
  uniqueText: string;
  currentPrice: string;
  roundedPrice: string;
  nextPrice: string;
  netReceive: string;
  payAmount: string;
  flagged: boolean;
  
  metadata: string;
  type: string;
  url: string;
  title: string;
  description: string;
  youTubeUrl: SafeResourceUrl;
  
  constructor(public _ngZone: NgZone,
    public route: ActivatedRoute,
    public contractService: ContractService,
    public contractDataService: ContractDataService,
    public marketplaceService: MarketplaceService,
    public sanitizer: DomSanitizer,
    public http: HttpClient) {
      this.route.queryParams.subscribe(params => {
        this.tag = params["tag"];
      });   
  }

  @HostListener('window:load')
  async windowLoaded() {
  }

  async ngOnInit() {
    await this.marketplaceService.init(this.tag);
  }
  
  public setModalId(index: number) {
    this.tokenId = this.marketplaceService.keywords[index].tokenId;
    this.uniqueText = this.marketplaceService.keywords[index].uniqueText;
    this.currentPrice = this.marketplaceService.keywords[index].currentPrice;
    this.roundedPrice = this.marketplaceService.keywords[index].roundedPrice;
    this.nextPrice = this.marketplaceService.keywords[index].nextPrice;
    this.netReceive = this.marketplaceService.keywords[index].netReceive;
    this.payAmount = this.marketplaceService.keywords[index].payAmount;
  }

  public clearData() {
    this.type = "";
    this.url = "";
    this.youTubeUrl = "";
  }
  public async setContentModal(index: number) { 
    const tokenId = this.marketplaceService.keywords[index].tokenId;
    this.clearData();
    const keyword = await this.contractDataService.assembleKeyword(tokenId);
    this.metadata = keyword.metadataString;
    this.type = keyword.metadata.type;
    this.flagged = keyword.flagged;

    if (keyword.metadata.type == "url") {
      if (!keyword.metadata.url) {
        this.type = "";
      } else {
        this.url = keyword.metadata.url;
        await this.scrape(keyword.metadata.url);
      }
    }

    if (keyword.metadata.type == "youtube") {
      if (!keyword.metadata.youtube) {
        this.type = "";
      } else {
        const myYouTubeUrl: string = "https://www.youtube.com/embed/" + keyword.metadata.youtube +
        "?autoplay=1&origin=https://cryptokeywords.com";
        this.youTubeUrl = this.sanitizer.bypassSecurityTrustResourceUrl(myYouTubeUrl);
      }
    }
  }

  public async scrape(url: string) {
    this.title = "Please wait. Loading content.";
    const urlMetadata = require('url-metadata');
    const newUrl = "https://crossorigin.me/" + url;
    this.http.get(newUrl, {responseType: 'text'})
    .subscribe((data) => {
      var el = document.createElement('html');
      el.innerHTML = data;
      this.title = this.getTitle(el);
      this.description = this.getDescription(el);
    });
  }

  public getTitle(el: any): string {
    var title = el.getElementsByTagName("title")[0].innerText;
    return title;
  }
  public getDescription(el: any): string { 
    var metas = el.getElementsByTagName("meta"); 
 
    var description = "(no description)";
    for (var i=0; i<metas.length; i++) { 
       if (metas[i].name.toLowerCase() == "description") { 
          description = metas[i].content; 
       } 
    } 
 
    return description;
 } 
  
}
