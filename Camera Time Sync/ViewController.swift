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

func getQrMessage() -> String {
    let date = getDateRfc3339()
    var message = "{date:'\(date)'"
    
    if let loc = CLLocationManager().location {
        message += ",lat=\(loc.coordinate.latitude),lon=\(loc.coordinate.longitude)"
    }
    
    message += "}"
    return message
}

class ViewController: UIViewController {
    
    @IBOutlet weak var qr: UIImageView!
    @IBOutlet weak var qrText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setQr() // what's a nib?
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setQr() {
        let message = getQrMessage()
        self.qrText.text = message
        self.qr.image = makeQr(message: message, width: self.qr.bounds.width, height: self.qr.bounds.height)
    }


}

