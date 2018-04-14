import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';
import { FaqComponent } from './faq.component';
import { FaqRoutingModule } from './faq.routing';

@NgModule({
  imports: [
    BrowserModule,
    FormsModule,
    HttpModule,
    FaqRoutingModule
  ],
  declarations: [
    FaqComponent
  ],
  bootstrap: [FaqComponent]
})
export class FaqModule { }
