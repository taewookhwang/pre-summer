import Foundation
import UIKit
import AVFoundation

protocol MediaServiceProtocol {
    // 이미지 관련 기능
    
    // 이미지 업로드
    func uploadImage(image: UIImage, type: MediaType, completion: @escaping (Result<String, Error>) -> Void)
    
    // 이미지 다운로드
    func downloadImage(from url: String, completion: @escaping (Result<UIImage, Error>) -> Void)
    
    // 이미지 캐싱
    func cacheImage(image: UIImage, for url: String)
    
    // 캐시 이미지 가져오기
    func getCachedImage(for url: String) -> UIImage?
    
    // 이미지 삭제
    func deleteImage(url: String, completion: @escaping (Result<Bool, Error>) -> Void)
    
    // 이미지 압축
    func compressImage(image: UIImage, quality: CGFloat) -> Data?
    
    // 이미지 크기 조정
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage
    
    // 오디오 관련 기능
    
    // 오디오 녹음 시작
    func startRecording(completion: @escaping (Result<Bool, Error>) -> Void)
    
    // 오디오 녹음 중지
    func stopRecording(completion: @escaping (Result<URL, Error>) -> Void)
    
    // 오디오 재생
    func playAudio(from url: URL, completion: @escaping (Result<Bool, Error>) -> Void)
    
    // 오디오 재생 중지
    func stopPlayingAudio()
    
    // 오디오 파일 업로드
    func uploadAudio(fileURL: URL, completion: @escaping (Result<String, Error>) -> Void)
    
    // 오디오 다운로드
    func downloadAudio(from url: String, completion: @escaping (Result<URL, Error>) -> Void)
    
    // 비디오 관련 기능
    
    // 비디오 녹화 시작
    func startVideoRecording(completion: @escaping (Result<Bool, Error>) -> Void)
    
    // 비디오 녹화 중지
    func stopVideoRecording(completion: @escaping (Result<URL, Error>) -> Void)
    
    // 비디오 재생
    func playVideo(from url: URL, in view: UIView, completion: @escaping (Result<Bool, Error>) -> Void)
    
    // 비디오 업로드
    func uploadVideo(fileURL: URL, completion: @escaping (Result<String, Error>) -> Void)
}

enum MediaType: String {
    case userProfile = "profile"
    case jobPhoto = "job"
    case servicePhoto = "service"
    case messageAttachment = "message"
    case review = "review"
}

enum MediaError: Error {
    case compressionFailed
    case downloadFailed
    case uploadFailed
    case fileNotFound
    case invalidFileFormat
    case recordingFailed
    case playbackFailed
    case permissionDenied
    case unknown(String)
}