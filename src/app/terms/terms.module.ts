import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';
import { TermsComponent } from './terms.component';
import { TermsRoutingModule } from './terms.routing';

@NgModule({
  imports: [
    BrowserModule,
    FormsModule,
    HttpModule,
    TermsRoutingModule
  ],
  declarations: [
    TermsComponent
  ],
  bootstrap: [TermsComponent]
})
export class TermsModule { }
