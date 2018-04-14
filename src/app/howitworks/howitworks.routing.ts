import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { HowItWorksComponent } from './howitworks.component';

const HOWITWORKS_ROUTES: Routes = [
    { path: 'howitworks', component: HowItWorksComponent, children: [
        { path: '**', component: HowItWorksComponent }
    ] }
];

@NgModule({
    imports: [
        RouterModule.forChild(HOWITWORKS_ROUTES)
    ],
    exports: [
        RouterModule
    ]
})
export class HowItWorksRoutingModule {}
