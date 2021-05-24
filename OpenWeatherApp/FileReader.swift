//
//  FileReader.swift
//  OpenWeatherApp
//
//  Created by Fahim Rahman on 17/4/21.
//

import Foundation

class FileReader {
    func readSecretKeyFile(forFileName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name, ofType: "json"), let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            } else {
                print("Error in do part in readSecretKeyFile()")
            }
        } catch {
            print("ERROR in readSecretKeyFile()", error)
        }
        return nil
    }

    func parseSecretKeyFile(jsonData: Data, keyFor: String) -> String? {
        do {
            let decodedSecretKeys = try JSONDecoder().decode(SecretKeysMap.self, from: jsonData)
            print("API key is", decodedSecretKeys.APIKEY_OPENWEATHERMAP)
            
            if keyFor == "openweathermap" {
                return decodedSecretKeys.APIKEY_OPENWEATHERMAP
            }
            else if keyFor == "mapBox"{
                return decodedSecretKeys.APIKEY_MAPBOX
            } else {
                print("Error in calling parseSecretKeyFile()")
            }
            
        } catch {
            print("Error in decoding parseSecretKeyFile()", error)
        }
        return nil
    }
}
