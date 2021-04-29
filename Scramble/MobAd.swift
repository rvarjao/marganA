//
//  MobAd.swift
//  Margana
//
//  Created by Ricardo Varjão on 29/04/21.
//

import Foundation

import GoogleMobileAds

func initBannerView(bannerView: GADBannerView,
                    viewController: UIViewController,
                    delegate: GADBannerViewDelegate,
                    testing: Bool = false){
    let key = testing ? "AD_MOB_PRODUCTION" : "AD_MOB_TESTING"
    bannerView.adUnitID = Bundle.main.object(forInfoDictionaryKey: key) as? String
    bannerView.rootViewController = viewController
    bannerView.load(GADRequest())
    bannerView.delegate = delegate
}
