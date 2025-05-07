import Foundation
import UIKit

protocol FileStorageProtocol {
    // 기본 파일 관리 메소드
    func saveFile(_ fileData: Data, withName fileName: String, inDirectory directory: String?) -> Bool
    func saveImage(_ image: UIImage, withName imageName: String, inDirectory directory: String?) -> Bool
    func loadFile(named fileName: String, fromDirectory directory: String?) -> Data?
    func loadImage(named imageName: String, fromDirectory directory: String?) -> UIImage?
    func deleteFile(named fileName: String, fromDirectory directory: String?) -> Bool
    func fileExists(named fileName: String, inDirectory directory: String?) -> Bool
    func getFileURL(named fileName: String, inDirectory directory: String?) -> URL?
    
    // Firebase Storage 호환 메소드
    func uploadData(data: Data, path: String, completion: @escaping (Result<String, Error>) -> Void)
    func downloadData(path: String, completion: @escaping (Result<Data, Error>) -> Void)
    func deleteFile(path: String, completion: @escaping (Result<Bool, Error>) -> Void)
}