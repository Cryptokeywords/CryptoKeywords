import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

const APP_ROUTES: Routes = [
    {
        path: '',
        redirectTo: 'home',
        pathMatch: 'full'
    },
    { path: 'marketplace', redirectTo: 'marketplace' },
    { path: 'keywords', redirectTo: 'keywords' },
    { path: 'keyword', redirectTo: 'keyword' },
    { path: 'profile', redirectTo: 'profile' },
    { path: 'portfolio', redirectTo: 'portfolio' },
    { path: 'home', redirectTo: 'home' },
    { path: 'faq', redirectTo: 'faq' },
    { path: 'howitworks', redirectTo: 'howitworks' },
    { path: 'terms', redirectTo: 'terms' },

    // All else fails - go home!
    { path: '**', redirectTo: 'home' }
];

@NgModule({
    imports: [
        RouterModule.forRoot(APP_ROUTES)
    ],
    exports: [
        RouterModule
    ]
})
export class AppRoutingModule {
}
