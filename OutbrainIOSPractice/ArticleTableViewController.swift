//
//  ViewController.swift
//  OutbrainIOSPractice
//
//  Created by Alon Shprung on 8/28/18.
//  Copyright © 2018 Alon Shprung. All rights reserved.
//

import UIKit
import OutbrainSDK
import Alamofire
import AlamofireImage
import SafariServices

class ArticleTableViewController: UITableViewController {
    
    let postURL = "http://mobile-demo.outbrain.com/2014/01/26/how-to-use-social-media-like-the-best-smb-marketers/"

    var recs:[OBRecommendation] = [OBRecommendation]()
    let originalTableViewSize = 1 // header only
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadPageContentOnScreen()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadPageContentOnScreen() {
        OBNetworkManager.sharedInstance.fetchOutbrainRecommendations(completion: { recs in
            if (recs != nil) {
                // fetch recommendations success
                self.recs = recs!;
                self.tableView.reloadData();
            }
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recs.count + self.originalTableViewSize;
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 40;
        default:
            return 120
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "OBHeaderCell", for: indexPath) as! OutbrainHeaderCell
            // register OBLable
            Outbrain.register(headerCell.recommendedToYouLabel, withWidgetId: OBNetworkManager.kOB_DEMO_WIDGET_ID, andUrl: postURL)
            
            // click on outbrain logo
            headerCell.outbrainLogoButtun.addTarget(self, action: #selector(self.userTappedOnOutbrainLogo), for: .touchUpInside)
            return headerCell
        default:
            let recCell = tableView.dequeueReusableCell(withIdentifier: "OBRecCell", for: indexPath) as! OutbrainRecCell
            let rec = self.recs[indexPath.row - self.originalTableViewSize]
            recCell.recTitleLabel.text = rec.content
            recCell.recSourceLabel.text = rec.source
            
            // Handle RTB
            if rec.isRTB {
                recCell.adChoicesButton.tag = indexPath.row
                recCell.adChoicesButton.isHidden = false
                if let adChoicesImageURL = rec.disclosure.imageUrl {
                    Alamofire.request(adChoicesImageURL).responseImage { response in
                        if let image = response.result.value {
                            recCell.adChoicesButton.setImage(image, for: .normal)
                        }
                    }
                }
                recCell.adChoicesButton.addTarget(self, action: #selector(self.adChoicesClicked), for: .touchUpInside)

            }
            else {
                recCell.adChoicesButton.isHidden = true
            }
            
            if let imageUrl = rec.image.url {
                Alamofire.request(imageUrl).responseImage { response in
                    if let image = response.result.value {
                        recCell.recImageView.image = image
                    }
                }
            }
            return recCell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row >= originalTableViewSize) {
            let rec = self.recs[indexPath.row - self.originalTableViewSize]
            self.userTappedOnRecommendation(rec)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc private func adChoicesClicked(sender: UIButton) {
        let rec = self.recs[sender.tag]
        if let clickURL = rec.disclosure.clickUrl {
            self.userTappedOnAdChoicesIcon(clickURL)
        }
    }
    
    func userTappedOnAdChoicesIcon(_ url: URL) {
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
    }
    
    @objc func userTappedOnOutbrainLogo() {
        guard let url = Outbrain.getAboutURL() else {
            return
        }
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
    }
    
    func userTappedOnRecommendation(_ rec: OBRecommendation) {
        guard let url = Outbrain.getUrl(rec) else {
            return
        }
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
    }
}

