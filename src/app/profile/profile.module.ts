import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';
import { ProfileComponent } from './profile.component';
import { ProfileService } from './profile.service';
import { ProfileRoutingModule } from './profile.routing';

@NgModule({
  imports: [
    BrowserModule,
    FormsModule,
    HttpModule,
    ProfileRoutingModule
  ],
  declarations: [
    ProfileComponent
  ],
  providers: [ProfileService],
  bootstrap: [ProfileComponent]
})
export class ProfileModule { }
