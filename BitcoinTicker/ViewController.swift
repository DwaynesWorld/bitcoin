//
//  ViewController.swift
//  BitcoinTicker
//
//  Created by Angela Yu on 23/01/2016.
//  Copyright © 2016 London App Brewery. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    let baseUrl = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTC"
    let currencies = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    let symbols = ["$", "R$", "$", "¥", "€", "£", "$", "Rp", "₪", "₹", "¥", "$", "kr", "$", "zł", "lei", "₽", "kr", "$", "$", "R"]
    
    var requestUrl = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTCUSD"
    var symbol = "$"
    var queue: DispatchQueue?
    var timer: DispatchSourceTimer?
    
    @IBOutlet weak var bitcoinPriceLabel: UILabel!
    @IBOutlet weak var currencyPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        currencyPicker.dataSource = self
        currencyPicker.delegate = self
        currencyPicker.selectRow(currencies.index(of: "USD")!, inComponent: 0, animated: true)
        
        queue = DispatchQueue.global(qos: .background)
        timer = DispatchSource.makeTimerSource(queue: queue)
        
        guard let timer = timer else { return }
        
        timer.schedule(deadline: .now(), repeating: .seconds(1), leeway: .seconds(1))
        timer.setEventHandler(handler: { self.getBitcoinData(url: self.requestUrl, parameters: [:]) })
        timer.resume()
    }
    
    //MARK: - PickerView Delegates
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencies[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        requestUrl = baseUrl + currencies[row]
        symbol = symbols[row]
    }

    //MARK: - Networking

    func getBitcoinData(url: String, parameters: [String : String]) {
        Alamofire.request(url, method: .get, parameters: parameters)
            .responseJSON { response in
                if response.result.isSuccess {
                    if let data = response.result.value {
                        print("Sucess! Got the bitcoin data")
                        let json = JSON(data)
                        DispatchQueue.main.async {
                            self.updateBitcoinUI(json: json)
                        }
                    } else {
                        print("Error: result parse error)")
                        DispatchQueue.main.async {
                            self.bitcoinPriceLabel.text = "Connection Issues"
                        }
                    }
                } else {
                    print("Error: \(String(describing: response.result.error))")
                    DispatchQueue.main.async {
                        self.bitcoinPriceLabel.text = "Connection Issues"
                    }
                }
            }
    }
    
   
    //MARK: - JSON Parsing

    func updateBitcoinUI(json : JSON) {
        if let result = json["last"].double {
            DispatchQueue.main.async {
                self.bitcoinPriceLabel.text = "\(self.symbol)\(result)"
            }
        }
    }
}

