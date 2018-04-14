import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { ProfileComponent } from './profile.component';

const PROFILE_ROUTES: Routes = [
    { path: 'profile', component: ProfileComponent, children: [
        { path: '**', component: ProfileComponent }
    ] }
];

@NgModule({
    imports: [
        RouterModule.forChild(PROFILE_ROUTES)
    ],
    exports: [
        RouterModule
    ]
})
export class ProfileRoutingModule {}
