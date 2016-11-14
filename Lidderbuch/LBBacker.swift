//
//  LBBacker.swift
//  Lidderbuch
//
//  Created by Fränz Friederes on 12/11/16.
//  Copyright © 2016 ACEL. All rights reserved.
//

import UIKit

class LBBacker: NSObject
{
    // contains an array of backer image urls
    var backers: [URL]!
    
    fileprivate var localBackerDirectoryURL: URL {
        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectoryURL.appendingPathComponent("backers")
    }
    
    override init()
    {
        super.init()
        
        // look for backer image files inside backer directory
        if let backerImageIds = try? FileManager.default.contentsOfDirectory(atPath: localBackerDirectoryURL.path) {
            backers = []
            // each backer image is named after the backer image id
            for backerImageId in backerImageIds {
                backers.append(localBackerDirectoryURL.appendingPathComponent(backerImageId))
            }
        } else {
            // no backer images could be located
            backers = []
        }
        
        // schedule backers update at low QOS in 2 seconds
        DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)
            .asyncAfter(deadline: .now() + 2.0) {
                self.update()
            }
    }
    
    func randomBackerImage() -> UIImage?
    {
        if let imageUrl = backers.random {
            // returns random backer image
            return UIImage(contentsOfFile: imageUrl.path)
        }
        return nil
    }
    
    func update()
    {
        // call backers endpoint
        let task = URLSession.shared.dataTask(
            with: URL(string: LBVariables.backerApiEndpoint)!,
            completionHandler: {
                (data, response, error) in
                if data != nil && error == nil {
                    self.integrateBackersWithData(data!)
                }
        })
        
        task.resume()
    }
    
    func integrateBackersWithData(_ data: Data)
    {
        let fileManager = FileManager.default
        
        // create backer directory if it does not exist yet
        if (!fileManager.fileExists(atPath: localBackerDirectoryURL.path)) {
            do {
                try fileManager.createDirectory(atPath: localBackerDirectoryURL.path, withIntermediateDirectories: false, attributes: nil)
            } catch _ as NSError {
                return
            }
        }
        
        var updatedBackers = [URL]()
        
        // try to read json data
        if let backersJson = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [AnyObject]
        {
            for backerJson in backersJson
            {
                // verify image id and url data
                if let backerImageId = backerJson["logo_id"] as? Int,
                   let backerImageUrlString = backerJson["logo_display_url"] as? String,
                   let backerImageUrl = URL(string: backerImageUrlString)
                {
                    let backer = localBackerDirectoryURL.appendingPathComponent(String(backerImageId))
                    updatedBackers.append(backer)
                    
                    // download backer
                    if !backers.contains(backer) {
                        let task = URLSession.shared.dataTask(
                            with: backerImageUrl,
                            completionHandler: { (data, response, error) in
                                
                                // save backer
                                try! data?.write(to: backer)
                            }
                        )
                        
                        task.resume()
                    }
                }
            }
        }
        
        // remove backers not included in latest backers list
        for backer in backers {
            // check if backer is still included
            if !updatedBackers.contains(backer) {
                // remove backer
                try! fileManager.removeItem(atPath: backer.path)
            }
        }
        
        backers = updatedBackers
    }
}
