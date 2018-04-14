import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';
import { HowItWorksComponent } from './howitworks.component';
import { HowItWorksRoutingModule } from './howitworks.routing';

@NgModule({
  imports: [
    BrowserModule,
    FormsModule,
    HttpModule,
    HowItWorksRoutingModule
  ],
  declarations: [
    HowItWorksComponent
  ],
  bootstrap: [HowItWorksComponent]
})
export class HowItWorksModule { }
