import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { PortfolioComponent } from './portfolio.component';

const PROTOTYPE_ROUTES: Routes = [
    { path: 'portfolio', component: PortfolioComponent, children: [
        { path: '**', component: PortfolioComponent }
    ] }
];

@NgModule({
    imports: [
        RouterModule.forChild(PROTOTYPE_ROUTES)
    ],
    exports: [
        RouterModule
    ]
})
export class PortfolioRoutingModule {}
