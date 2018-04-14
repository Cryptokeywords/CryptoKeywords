import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { FaqComponent } from './faq.component';

const HOME_ROUTES: Routes = [
    { path: 'faq', component: FaqComponent, children: [
        { path: '**', component: FaqComponent }
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
export class FaqRoutingModule {}
