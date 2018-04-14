import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';
import { HomeComponent } from './home.component';
import { HomeRoutingModule } from './home.routing';

@NgModule({
  imports: [
    BrowserModule,
    FormsModule,
    HttpModule,
    HomeRoutingModule
  ],
  declarations: [
    HomeComponent
  ],
  bootstrap: [HomeComponent]
})
export class HomeModule { }
