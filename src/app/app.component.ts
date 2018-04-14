import { Component, OnInit, OnDestroy, Inject, Injector, ViewEncapsulation, RendererFactory2, PLATFORM_ID } from '@angular/core';
import { Web3Service } from '../common/web3.service';
import { Router, NavigationEnd, ActivatedRoute, PRIMARY_OUTLET } from '@angular/router';

declare let window: any;

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {

  constructor(public web3Service: Web3Service) {
  }
}
