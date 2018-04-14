import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { KeywordsComponent } from './keywords.component';

const KEYWORDS_ROUTES: Routes = [
    { path: 'keywords', component: KeywordsComponent, children: [
        { path: '**', component: KeywordsComponent }
    ] }
];

@NgModule({
    imports: [
        RouterModule.forChild(KEYWORDS_ROUTES)
    ],
    exports: [
        RouterModule
    ]
})
export class KeywordsRoutingModule {}
