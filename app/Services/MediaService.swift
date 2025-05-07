import Foundation
import UIKit
import AVFoundation

class MediaService: MediaServiceProtocol {
    static let shared = MediaService()
    
    private init() {
        setupAudioSession()
    }
    
    // 의존성
    private let fileStorageManager = FileStorageManager.shared
    
    // 오디오 관련 변수
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingURL: URL?
    
    // 이미지 캐싱
    private var imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100  // 최대 이미지 개수 제한
        cache.totalCostLimit = 50 * 1024 * 1024  // 최대 50MB 제한
        return cache
    }()
    
    // MARK: - 이미지 관련 기능
    
    func uploadImage(image: UIImage, type: MediaType, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(.failure(MediaError.compressionFailed))
            return
        }
        
        let fileName = "\(UUID().uuidString).jpg"
        let path = "images/\(type.rawValue)/\(fileName)"
        
        fileStorageManager.uploadData(data: imageData, path: path, completion: { result in
            switch result {
            case .success(let url):
                // 업로드 성공시 캐싱
                self.cacheImage(image: image, for: url)
                completion(.success(url))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func downloadImage(from url: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        // 캐시 확인
        if let cachedImage = getCachedImage(for: url) {
            completion(.success(cachedImage))
            return
        }
        
        // 서버에서 다운로드
        fileStorageManager.downloadData(path: url, completion: { result in
            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    completion(.failure(MediaError.invalidFileFormat))
                    return
                }
                
                // 이미지 캐시에 저장
                self.cacheImage(image: image, for: url)
                completion(.success(image))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func cacheImage(image: UIImage, for url: String) {
        let key = NSString(string: url)
        imageCache.setObject(image, forKey: key)
    }
    
    func getCachedImage(for url: String) -> UIImage? {
        let key = NSString(string: url)
        return imageCache.object(forKey: key)
    }
    
    func deleteImage(url: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        // 캐시에서 제거
        let key = NSString(string: url)
        imageCache.removeObject(forKey: key)
        
        // 서버에서 제거
        fileStorageManager.deleteFile(path: url, completion: { result in
            switch result {
            case .success:
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func compressImage(image: UIImage, quality: CGFloat) -> Data? {
        return image.jpegData(compressionQuality: quality)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        // 비율을 유지하며 크기 조정
        let scaleFactor = min(widthRatio, heightRatio)
        
        let scaledWidth = size.width * scaleFactor
        let scaledHeight = size.height * scaleFactor
        
        let targetRect = CGRect(
            x: (targetSize.width - scaledWidth) / 2,
            y: (targetSize.height - scaledHeight) / 2,
            width: scaledWidth,
            height: scaledHeight
        )
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0)
        image.draw(in: targetRect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    // MARK: - 오디오 관련 기능
    
    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            print("오디오 세션 설정 실패: \(error.localizedDescription)")
        }
    }
    
    func startRecording(completion: @escaping (Result<Bool, Error>) -> Void) {
        // 오디오 녹음 파일의 임시 경로 생성
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
        recordingURL = audioFilename
        
        // 녹음 설정
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            completion(.success(true))
        } catch {
            completion(.failure(error))
        }
    }
    
    func stopRecording(completion: @escaping (Result<URL, Error>) -> Void) {
        guard let recorder = audioRecorder, recorder.isRecording, let url = recordingURL else {
            completion(.failure(MediaError.recordingFailed))
            return
        }
        
        recorder.stop()
        audioRecorder = nil
        completion(.success(url))
    }
    
    func playAudio(from url: URL, completion: @escaping (Result<Bool, Error>) -> Void) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            completion(.success(true))
        } catch {
            completion(.failure(error))
        }
    }
    
    func stopPlayingAudio() {
        audioPlayer?.stop()
    }
    
    func uploadAudio(fileURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            let audioData = try Data(contentsOf: fileURL)
            let fileName = fileURL.lastPathComponent
            let path = "audio/\(fileName)"
            
            fileStorageManager.uploadData(data: audioData, path: path, completion: { result in
                switch result {
                case .success(let url):
                    completion(.success(url))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        } catch {
            completion(.failure(error))
        }
    }
    
    func downloadAudio(from url: String, completion: @escaping (Result<URL, Error>) -> Void) {
        fileStorageManager.downloadData(path: url, completion: { result in
            switch result {
            case .success(let data):
                // 임시 파일 생성
                let tempDir = FileManager.default.temporaryDirectory
                let fileURL = tempDir.appendingPathComponent("\(UUID().uuidString).m4a")
                
                do {
                    try data.write(to: fileURL)
                    completion(.success(fileURL))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    // MARK: - 비디오 관련 기능
    
    func startVideoRecording(completion: @escaping (Result<Bool, Error>) -> Void) {
        // 실제 구현은 AVCaptureSession을 사용해 비디오 녹화 구현
        // 임시로 모킹 레이어 구현
        completion(.success(true))
    }
    
    func stopVideoRecording(completion: @escaping (Result<URL, Error>) -> Void) {
        // 실제 구현은 AVCaptureSession 녹화 종료 및 파일 저장
        // 임시로 모킹 레이어 구현
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("video_\(UUID().uuidString).mp4")
        completion(.success(tempURL))
    }
    
    func playVideo(from url: URL, in view: UIView, completion: @escaping (Result<Bool, Error>) -> Void) {
        // 실제 구현은 AVPlayer를 사용해 비디오 재생
        // 임시로 모킹 레이어 구현
        completion(.success(true))
    }
    
    func uploadVideo(fileURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            let videoData = try Data(contentsOf: fileURL)
            let fileName = fileURL.lastPathComponent
            let path = "videos/\(fileName)"
            
            fileStorageManager.uploadData(data: videoData, path: path, completion: { result in
                switch result {
                case .success(let url):
                    completion(.success(url))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        } catch {
            completion(.failure(error))
        }
    }
}