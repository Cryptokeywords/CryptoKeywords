import { Component, OnInit, HostListener, NgZone } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';
import { Router, ActivatedRoute } from '@angular/router';
import { NavigationEnd } from '@angular/router';
import { ContractService } from '../../common/contract.service';
import { ContractDataService } from '../data/contractdata.service';
import { KeywordService } from './keyword.service';
import { Keyword } from '../data/keyword';
import { Metadata } from '../data/metadata';
import { Key } from 'protractor';
import { Meta } from '@angular/platform-browser';

declare var window: any;

@Component({
  selector: 'app-keyword',
  templateUrl: './keyword.component.html'
})
export class KeywordComponent implements OnInit {
  tokenId: string;
  keyword: Keyword;
  sub: any;

  typeEdit: string;
  urlEdit: string;
  youTubeEdit: string;

  type: string;
  url: string;
  title: string;
  description: string;
  youTubeUrl: SafeResourceUrl;

  constructor(public _ngZone: NgZone,
    public contractService: ContractService,
    public contractDataService: ContractDataService,
    public keywordService: KeywordService,
    public router: Router,
    public route: ActivatedRoute,
    public sanitizer: DomSanitizer,
    public http: HttpClient) {
      this.keyword = new Keyword();
      this.keyword.metadata = new Metadata();
      this.route.queryParams.subscribe(params => {
        this.tokenId = params["id"];
        });    
  }

  @HostListener('window:load')
  windowLoaded() {
  }

  async ngOnInit() {
    await this.keywordService.init(this.tokenId);
    await this.refresh();
  }

  public async refresh() {
    this.keyword = await this.contractDataService.assembleKeyword(this.tokenId);

    if (this.keyword.metadata) {
      this.typeEdit = this.keyword.metadata.type;
      this.urlEdit = this.keyword.metadata.url;
      this.youTubeEdit = this.keyword.metadata.youtube;
    }
  }

  public async setMetadata() {
    this.cleanData();
    let metadata = new Metadata();
    metadata.type = this.typeEdit;
    metadata.url = this.urlEdit;
    metadata.youtube = this.youTubeEdit;
    await this.contractDataService.setMetadata(this.tokenId, metadata);
  }

  public cleanData() {
    if (this.typeEdit == "url") {
      this.youTubeEdit = "";
    }
    if (this.typeEdit == "youtube") {
      this.urlEdit = "";
    }
  }

  public async setContentModal() { 
    const keyword = this.keyword;
    if (keyword.metadata) {
      this.type = keyword.metadata.type;

      if (keyword.metadata.type == "url") {
        this.url = keyword.metadata.url;
  
        if (!this.url) {
          this.type = "";
        }
  
        await this.scrape(keyword.metadata.url);
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
