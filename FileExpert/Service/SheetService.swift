//
//  GoogleService.swift
//  FileExpert
//
//  Created by new on 5/27/21.
//

import GoogleSignIn
import GoogleAPIClientForREST

class SheetService {
    
    static let shared = SheetService()
    
    private static let SREADSHEET_ID = "1oL1cByCpMXJMz6ifaKDiK6bZC2xE2HkRA4jwHRtRuj8"
    private static let RANGE = "Sheet1"
    private static let API_KEY = "AIzaSyBUXS1Crn_5IxInmyZhw6XoA0P43JbV4Zc"
    
    private let service = GTLRSheetsService()
    
    func fetchSheet(completion: @escaping (Sheet?, Error?) -> ()) {
        var sheet = Sheet()
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(
                withSpreadsheetId: SheetService.SREADSHEET_ID,
                range: SheetService.RANGE)
        
        service.apiKey = SheetService.API_KEY
        
        service.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let valueRange = result as? GTLRSheets_ValueRange, let rows = valueRange.values as? [[String]] else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Incorrect spreadsheet format"]) as Error
                completion(nil, error)
                return
            }
            
            var error: Error?
            for row in rows {
                if (row.count != 4) {
                    error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error: incorrect spreadsheet format"]) as Error
                } else {
                    sheet.rows.append(SheetRecord(id: row[0], parentFolder: row[1], type: row[2], name: row[3]))
                }
            }
            completion(sheet, error)
        }
    }
}

