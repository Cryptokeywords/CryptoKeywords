import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';
import { HttpClientModule } from '@angular/common/http';
import { KeywordComponent } from './keyword.component';
import { KeywordService } from './keyword.service';
import { KeywordRoutingModule } from './keyword.routing';

@NgModule({
  imports: [
    BrowserModule,
    FormsModule,
    HttpModule,
    HttpClientModule,
    KeywordRoutingModule
  ],
  declarations: [
    KeywordComponent
  ],
  providers: [KeywordService],
  bootstrap: [KeywordComponent]
})
export class KeywordModule { }
