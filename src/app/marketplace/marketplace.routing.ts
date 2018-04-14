import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { MarketplaceComponent } from './marketplace.component';

const PROTOTYPE_ROUTES: Routes = [
    { path: 'marketplace', component: MarketplaceComponent }
];

@NgModule({
    imports: [
        RouterModule.forChild(PROTOTYPE_ROUTES)
    ],
    exports: [
        RouterModule
    ]
})
export class MarketplaceRoutingModule {}
