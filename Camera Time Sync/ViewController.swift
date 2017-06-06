//
//  ViewController.swift
//  Camera Time Sync
//
//  Created by Alexander Brodie on 5/15/17.
//  Copyright © 2017 Alexander Brodie. All rights reserved.
//

import UIKit
import CoreLocation

func makeQr(message: String, width: CGFloat, height: CGFloat) -> UIImage {
    // Generate QR
    let filter = CIFilter(name:"CIQRCodeGenerator")!
    let data = message.data(using: String.Encoding.utf8)
    filter.setValue(data, forKey: "inputMessage")
    
    // Scale to fit
    let dims = filter.outputImage!.extent;
    let trans = CGAffineTransform(scaleX: width / dims.width, y: height / dims.height)
    let output = filter.outputImage!.applying(trans)
    
    // Complete!
    return UIImage(ciImage: output)
}

func getDateRfc3339() -> String {
    // Get date/time with time-zone information as RFC 3339
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = NSTimeZone.local
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    return formatter.string(from: Date())
}

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var qr: UIImageView!
    @IBOutlet weak var qrText: UILabel!
    
    var locMgr: CLLocationManager!
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Start getting GPS info
        initLocMgr()
        
        // Set initial output
        setQr()
        
        // Refresh periodically to keep displayed timestamp current
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { [weak self] (timer:Timer) in self!.setQr() })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initLocMgr() {
        // Reference: https://developer.apple.com/reference/corelocation/cllocationmanager#1669513
        let status = CLLocationManager.authorizationStatus()
        if (status != CLAuthorizationStatus.denied && status != CLAuthorizationStatus.restricted) {
            let lm = CLLocationManager()
            
            lm.delegate = self
            lm.desiredAccuracy = kCLLocationAccuracyBest
            lm.distanceFilter = 100 * kCLLocationAccuracyKilometer
            
            if (status == CLAuthorizationStatus.notDetermined) {
                lm.requestWhenInUseAuthorization()
            }

            // TODO?: lm.startMonitoring(for:)
            // TODO?: lm.startMonitoringSignificantLocationChanges()

            lm.requestLocation()

            self.locMgr = lm
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TODO: Error UI
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status != CLAuthorizationStatus.denied && status != CLAuthorizationStatus.restricted) {
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        setQr()
    }
    
    func getQrMessage() -> String {
        let date = getDateRfc3339()
        var message = "{\"date\":\"\(date)\""
        
        if let loc = locMgr?.location {
            message += ",\"lat\":\(loc.coordinate.latitude),\"lon\":\(loc.coordinate.longitude)"
        }
        
        message += "}"
        return message
    }
    
    func getQrMessage2() -> String {
        // For testing purposes, put info that's easy to verify that time/GPS/QR stuff is working
        if let loc = locMgr?.location {
            return "https://www.google.com/maps/@\(loc.coordinate.latitude),\(loc.coordinate.longitude),15z"
        } else {
            return "No location information available"
        }
    }

    func setQr() {
        let message = getQrMessage()
        if (self.qrText.text != message) {
            self.qrText.text = message
            self.qr.image = makeQr(message: message, width: self.qr.bounds.width, height: self.qr.bounds.height)
        }
    }


}




