import Foundation
import UIKit

class FileStorageManager: FileStorageProtocol {
    static let shared = FileStorageManager()
    
    private init() {}
    
    // 문서 디렉토리 경로 반환
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // 경로 URL 반환 (및 디렉토리 생성)
    private func getDirectoryURL(_ directory: String?) -> URL {
        let documentsURL = getDocumentsDirectory()
        
        if let directory = directory {
            let directoryURL = documentsURL.appendingPathComponent(directory)
            
            // 디렉토리 존재하지 않으면 생성
            if !FileManager.default.fileExists(atPath: directoryURL.path) {
                do {
                    try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
                } catch {
                    print("FileStorageManager - Failed to create directory: \(error.localizedDescription)")
                }
            }
            
            return directoryURL
        }
        
        return documentsURL
    }
    
    // 파일 저장
    func saveFile(_ fileData: Data, withName fileName: String, inDirectory directory: String? = nil) -> Bool {
        let fileURL = getDirectoryURL(directory).appendingPathComponent(fileName)
        
        do {
            try fileData.write(to: fileURL)
            return true
        } catch {
            print("FileStorageManager - Failed to save file: \(error.localizedDescription)")
            return false
        }
    }
    
    // 이미지 저장
    func saveImage(_ image: UIImage, withName imageName: String, inDirectory directory: String? = nil) -> Bool {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("FileStorageManager - Failed to convert image to data")
            return false
        }
        
        return saveFile(imageData, withName: imageName, inDirectory: directory)
    }
    
    // 파일 로드
    func loadFile(named fileName: String, fromDirectory directory: String? = nil) -> Data? {
        let fileURL = getDirectoryURL(directory).appendingPathComponent(fileName)
        
        do {
            return try Data(contentsOf: fileURL)
        } catch {
            print("FileStorageManager - Failed to load file: \(error.localizedDescription)")
            return nil
        }
    }
    
    // 이미지 로드
    func loadImage(named imageName: String, fromDirectory directory: String? = nil) -> UIImage? {
        guard let imageData = loadFile(named: imageName, fromDirectory: directory) else {
            return nil
        }
        
        return UIImage(data: imageData)
    }
    
    // 파일 삭제
    func deleteFile(named fileName: String, fromDirectory directory: String? = nil) -> Bool {
        let fileURL = getDirectoryURL(directory).appendingPathComponent(fileName)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            return true
        } catch {
            print("FileStorageManager - Failed to delete file: \(error.localizedDescription)")
            return false
        }
    }
    
    // 파일 존재 여부 확인
    func fileExists(named fileName: String, inDirectory directory: String? = nil) -> Bool {
        let fileURL = getDirectoryURL(directory).appendingPathComponent(fileName)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    // 파일 URL 반환
    func getFileURL(named fileName: String, inDirectory directory: String? = nil) -> URL? {
        let fileURL = getDirectoryURL(directory).appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return fileURL
        }
        
        return nil
    }
    
    // MARK: - Firebase Storage 호환 메소드
    
    // uploadData - Firebase Storage 호환 메소드
    func uploadData(data: Data, path: String, completion: @escaping (Result<String, Error>) -> Void) {
        // 경로에서 디렉토리와 파일 이름 분리
        let pathComponents = path.components(separatedBy: "/")
        let fileName = pathComponents.last ?? "\(UUID().uuidString).dat"
        let directory = pathComponents.count > 1 ? pathComponents.dropLast().joined(separator: "/") : nil
        
        // 로컬 파일 시스템에 저장
        if saveFile(data, withName: fileName, inDirectory: directory) {
            // 성공 시 가상 URL 반환 (실제 앱에서는 Firebase Storage URL)
            let fileURL = getDirectoryURL(directory).appendingPathComponent(fileName).absoluteString
            completion(.success(fileURL))
        } else {
            completion(.failure(NSError(domain: "FileStorageManager", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Failed to upload data"])))
        }
    }
    
    // downloadData - Firebase Storage 호환 메소드
    func downloadData(path: String, completion: @escaping (Result<Data, Error>) -> Void) {
        // URL 형식이면 파일 경로로 변환
        let path = path.hasPrefix("file://") ? String(path.dropFirst(7)) : path
        
        // 경로에서 디렉토리와 파일 이름 분리
        let pathComponents = path.components(separatedBy: "/")
        let fileName = pathComponents.last ?? ""
        let directory = pathComponents.count > 1 ? pathComponents.dropLast().joined(separator: "/") : nil
        
        // 파일 로드
        if let data = loadFile(named: fileName, fromDirectory: directory) {
            completion(.success(data))
        } else {
            completion(.failure(NSError(domain: "FileStorageManager", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Failed to download data"])))
        }
    }
    
    // deleteFile - Firebase Storage 호환 메소드
    func deleteFile(path: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        // 경로에서 디렉토리와 파일 이름 분리
        let pathComponents = path.components(separatedBy: "/")
        let fileName = pathComponents.last ?? ""
        let directory = pathComponents.count > 1 ? pathComponents.dropLast().joined(separator: "/") : nil
        
        if deleteFile(named: fileName, fromDirectory: directory) {
            completion(.success(true))
        } else {
            completion(.failure(NSError(domain: "FileStorageManager", code: 1003, userInfo: [NSLocalizedDescriptionKey: "Failed to delete file"])))
        }
    }
}