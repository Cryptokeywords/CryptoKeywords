import { NgModule, Inject } from '@angular/core';
import { RouterModule } from '@angular/router';
import { CommonModule, APP_BASE_HREF } from '@angular/common';
import { HttpModule, Http } from '@angular/http';
import { BrowserModule } from '@angular/platform-browser';
import { FormsModule } from '@angular/forms';

// app elements
import { AppRoutingModule } from './approuting.module';
import { AppComponent } from './app.component';

// child modules
import { DataModule } from './data/data.module';
import { UtilModule } from '../common/util.module';
import { MarketplaceModule } from './marketplace/marketplace.module';
import { KeywordsModule } from './keywords/keywords.module';
import { KeywordModule } from './keyword/keyword.module';
import { ProfileModule } from './profile/profile.module';
import { PortfolioModule } from './portfolio/portfolio.module';
import { HomeModule } from './home/home.module';
import { FaqModule } from './faq/faq.module';
import { HowItWorksModule } from './howitworks/howitworks.module';
import { TermsModule } from './terms/terms.module';

@NgModule({
  declarations: [
    AppComponent
  ],
  imports: [
    CommonModule,
    HttpModule,
    FormsModule,
    BrowserModule,
    AppRoutingModule,
    DataModule,
    UtilModule,
    MarketplaceModule,
    KeywordsModule,
    KeywordModule,
    ProfileModule,
    PortfolioModule,
    HomeModule,
    FaqModule,
    HowItWorksModule,
    TermsModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
