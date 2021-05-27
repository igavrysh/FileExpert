//
//  FolderViewController.swift
//  FileExpert
//
//  Created by new on 5/27/21.
//

import UIKit
import Foundation
import GoogleAPIClientForREST

class FolderViewController: UIViewController {
    
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheets]
    private let service = GTLRSheetsService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blue
        fetchSheet()
    }
    
    func fetchSheet() {
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: "1oL1cByCpMXJMz6ifaKDiK6bZC2xE2HkRA4jwHRtRuj8", range: "Sheet1")
        service.apiKey = "AIzaSyBUXS1Crn_5IxInmyZhw6XoA0P43JbV4Zc"
        service.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let valueRange = result as? GTLRSheets_ValueRange, let rows = valueRange.values as? [[String]] {
                for row in rows {
                    print("\(row)")
                }
            }
        }
        
        /*
        let sheetId = "1oL1cByCpMXJMz6ifaKDiK6bZC2xE2HkRA4jwHRtRuj8"
        let range = "A1:D37"
        let urlString = "https://sheets.googleapis.com/v4/spreadsheets/\(sheetId)/values/Sheet1!\(range)"
        guard let url = URL(string: urlString) else {
            print("error creating url")
            return
        }
        
        URLSession.shared.dataTask(with: url) {(data, resp, err) in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            
            print(resp)
            
        }.resume()*/
    }
}
