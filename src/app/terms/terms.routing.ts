import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { TermsComponent } from './terms.component';

const HOME_ROUTES: Routes = [
    { path: 'terms', component: TermsComponent, children: [
        { path: '**', component: TermsComponent }
    ] }
];

@NgModule({
    imports: [
        RouterModule.forChild(HOME_ROUTES)
    ],
    exports: [
        RouterModule
    ]
})
export class TermsRoutingModule {}
