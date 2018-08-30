//
//  OBHelper.swift
//  OutbrainIOSPractice
//
//  Created by Alon Shprung on 8/28/18.
//  Copyright © 2018 Alon Shprung. All rights reserved.
//

import Foundation
import Alamofire
import OutbrainSDK

class OBNetworkManager {
    static let sharedInstance = OBNetworkManager()
    static let kOB_DEMO_WIDGET_ID = "SDK_2"
    static let postURL = "http://mobile-demo.outbrain.com/2014/01/26/how-to-use-social-media-like-the-best-smb-marketers/"

    
    func fetchOutbrainRecommendations(completion: @escaping (_ recs: [OBRecommendation]?) -> Void) {
        let request = OBRequest(url: OBNetworkManager.postURL, widgetID: OBNetworkManager.kOB_DEMO_WIDGET_ID, widgetIndex: 0)
        
        Outbrain.fetchRecommendations(for: request) { response in
            completion(response?.recommendations as? [OBRecommendation])
        }
    }

}
