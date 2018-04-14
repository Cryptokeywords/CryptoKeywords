import { Metadata } from './metadata';
import { SafeResourceUrl } from '@angular/platform-browser';

export class Keyword {
    tokenId: string;
    uniqueText: string;
    mintTime: string;
    currentPrice: string;
    roundedPrice: string;
    currentPriceWei: string;
    nextPrice: string;
    netReceive: string;
    trades: string;
    owner: string;
    nickname: string;
    colorHash: string;
    payAmount: string;
    metadataString: string;
    metadataAvailable: boolean;
    metadata: Metadata;
    flagged: boolean;

    youTubeUrl: SafeResourceUrl;
    webTitle: string;
    webDescription: string;
}