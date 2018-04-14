import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';
import { MarketplaceComponent } from './marketplace.component';
import { MarketplaceService } from './marketplace.service';
import { MarketplaceRoutingModule } from './marketplace.routing';

@NgModule({
  imports: [
    BrowserModule,
    FormsModule,
    HttpModule,
    MarketplaceRoutingModule
  ],
  declarations: [
    MarketplaceComponent
  ],
  providers: [MarketplaceService],
  bootstrap: [MarketplaceComponent]
})
export class MarketplaceModule { }
