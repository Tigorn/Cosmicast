//
//  FeedImporterDatasourceAEXML.swift
//  CosmoCast
//
//  Created by Shihab Mehboob on 07/09/2018.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import Foundation
import AEXML
import UIKit

struct FeedImporterDatasourceAEXML: FeedImporterDatasource {
    
    var urls: [URL]?
    
    // MARK: - FeedImporterDatasource
    init(data: Data) {
        do {
            let xml = try AEXMLDocument(xml: data)
            urls = [URL]()
            let outlines0 = xml.root["body"]["outline"]["outline"]
            for outline in outlines0.children {
                guard let urlString = outline.attributes["xmlUrl"] else { continue }
                guard let url = URL(string: urlString) else { continue }
                urls!.append(url)
            }
            let outlines = xml.root["body"]["outline"]
            for outline in outlines.children {
                guard let urlString = outline.attributes["xmlUrl"] else { continue }
                guard let url = URL(string: urlString) else { continue }
                urls!.append(url)
            }
            let outlines2 = xml.root["body"]
            for outline2 in outlines2.children {
                guard let urlString = outline2.attributes["xmlUrl"] else { continue }
                guard let url = URL(string: urlString) else { continue }
                urls!.append(url)
            }
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}

protocol FeedImporterDatasource {
    var urls: [URL]? { get }
}
