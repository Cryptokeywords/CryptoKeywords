import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { KeywordComponent } from './keyword.component';

const KEYWORD_ROUTES: Routes = [
    { path: 'keyword', component: KeywordComponent, children: [
        { path: ':id', component: KeywordComponent }
    ] }
];

@NgModule({
    imports: [
        RouterModule.forChild(KEYWORD_ROUTES)
    ],
    exports: [
        RouterModule
    ]
})
export class KeywordRoutingModule {}
