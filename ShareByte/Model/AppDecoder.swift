//
//  Compressor.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 11/11/23.
//

import Foundation

struct AppDecoder {
    static func compress(data: Data) -> NSData? {
        do {
            let compressedData = try (data as NSData).compressed(using: .lz4)
            return compressedData
            // use your compressed data
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    static func decompress(nsData: NSData) -> Data? {
        do {
            let decompressedData = try nsData.decompressed(using: .lz4) as Data
            return decompressedData
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    static func stringToData(_ str: String) -> Data {
        return Data(str.utf8)
    }
    
    static func dataToString(_ data: Data) -> String {
        return String(decoding: data, as: UTF8.self)
    }
}

