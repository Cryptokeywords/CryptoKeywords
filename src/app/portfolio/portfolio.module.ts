import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';
import { PortfolioComponent } from './portfolio.component';
import { PortfolioService } from './portfolio.service';
import { PortfolioRoutingModule } from './portfolio.routing';

@NgModule({
  imports: [
    BrowserModule,
    FormsModule,
    HttpModule,
    PortfolioRoutingModule
  ],
  declarations: [
    PortfolioComponent
  ],
  providers: [PortfolioService],
  bootstrap: [PortfolioComponent]
})
export class PortfolioModule { }
