import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';
import { KeywordsComponent } from './keywords.component';
import { KeywordsService } from './keywords.service';
import { KeywordsRoutingModule } from './keywords.routing';

@NgModule({
  imports: [
    BrowserModule,
    FormsModule,
    HttpModule,
    KeywordsRoutingModule
  ],
  declarations: [
    KeywordsComponent
  ],
  providers: [KeywordsService],
  bootstrap: [KeywordsComponent]
})
export class KeywordsModule { }
