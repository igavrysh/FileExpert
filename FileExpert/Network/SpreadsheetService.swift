//
//  GoogleService.swift
//  FileExpert
//
//  Created by new on 5/27/21.
//

import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher

class SpreadsheetService {
    
    static let shared = SpreadsheetService()
    
    private static let SREADSHEET_ID = "1rcSWbPMhxGrDCAmge9x8Yr7k8wHVijP1jsiEZpv_Bfk"
    private static let RANGE = "Sheet1"
    private static let API_KEY = "AIzaSyBUXS1Crn_5IxInmyZhw6XoA0P43JbV4Zc"
    
    private let service = GTLRSheetsService()
    
    func loadRecords(_ completion: @escaping (Result<[SheetRecord]>) -> ()) -> NetworkTask {
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(
                withSpreadsheetId: SpreadsheetService.SREADSHEET_ID,
                range: SpreadsheetService.RANGE)
        service.apiKey = SpreadsheetService.API_KEY

        let t = service.executeQuery(query) { (ticket, result, error) in
            DispatchQueue.global(qos: .background).async {
                if let e = error {
                    DispatchQueue.main.async {
                        completion(.error(e))
                    }
                    return
                }
                
                guard let valueRange = result as? GTLRSheets_ValueRange,
                      let rows = valueRange.values as? [[String]]
                else {
                    DispatchQueue.main.async {
                        completion(.error(self.errorWithDesc("Incorrect spreadsheet format, other than string values in cells")))
                    }
                    return
                }
                
                var sheetRecrods: [SheetRecord] = []
                for row in rows {
                    // load only those items that are attached to current folder
                    // TODO: review this logic and adjust when switched to prod level API
                    if (row.count != 4) {
                        completion(.error(self.errorWithDesc("Incorrect spreadsheet format, number of columns not equal 4")))
                        return
                    } else {
                        guard let type = SheetRecordType(rawValue: row[2])
                        else {
                            completion(.error(self.errorWithDesc("Incorrect spreadsheet format, record type is other then f - file or d - directory")))
                            return
                        }
                        sheetRecrods.append(SheetRecord(id: row[0], parentId: row[1], type: type, name: row[3]))
                    }
                }
                DispatchQueue.main.async {
                    completion(.success(sheetRecrods))
                }
            }
        }
        return SpreadsheetNetworkTask(with: t)
    }
    
    func addRecord(_ sheetRecord: SheetRecord, completion: @escaping (Result<SheetRecord>) -> ()) -> NetworkTask? {
        let valueRange = GTLRSheets_ValueRange.init();
        valueRange.values = [[sheetRecord.id, sheetRecord.parentId, sheetRecord.type.rawValue, sheetRecord.name]]
        let query = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(
            withObject: valueRange,
            spreadsheetId: SpreadsheetService.SREADSHEET_ID,
            range: SpreadsheetService.RANGE)
        query.valueInputOption = kGTLRSheetsValueInputOptionUserEntered
        query.includeValuesInResponse = true
        guard let currentUser = GIDSignIn.sharedInstance().currentUser
        else {
            completion(.error(errorWithDesc("Please, authorize with 👤 button to add items")))
            return nil
        }
        service.authorizer = currentUser.authentication.fetcherAuthorizer()
        let t = service.executeQuery(query) { (ticket, result, error) in
            if let e = error {
                completion(.error(e))
                return
            }
        
            guard let respone = (result as? GTLRSheets_AppendValuesResponse)?.updates
            else {
                completion(.error(self.errorWithDesc("Incorrect spreadsheet format")))
                return
            }
            
            guard let valueRange = respone.updatedData,
                  let rows = valueRange.values as? [[String]]
            else {
                completion(.error(self.errorWithDesc("Incorrect spreadsheet update during adding records")))
                return
            }
            
            guard let row = rows.first else {
                completion(.error(self.errorWithDesc("Incorrect updated rows")))
                return
            }
            
            guard let type = SheetRecordType(rawValue: row[2])
            else {
                completion(.error(self.errorWithDesc("Incorrect spreadsheet format after record adding, record type is other then f - file or d - directory")))
                return
            }
        
            let newRecord = SheetRecord(id: row[0], parentId: row[1], type: type, name: row[3])
            completion(.success(newRecord))
        }
        return  SpreadsheetNetworkTask(with: t)
    }
    
    private func errorWithDesc(_ desc: String) -> Error {
        return NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: desc]) as Error
    }
}

