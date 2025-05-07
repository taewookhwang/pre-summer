import Foundation
import CoreLocation

class LocationService: NSObject, LocationServiceProtocol {
    static let shared = LocationService()
    
    // 의존성
    private let locationManager = CLLocationManager()
    private var currentLocationCompletion: ((Result<CLLocation, Error>) -> Void)?
    private var geocoder = CLGeocoder()
    
    weak var delegate: LocationServiceDelegate?
    
    var authorizationStatus: CLAuthorizationStatus {
        return locationManager.authorizationStatus
    }
    
    private override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10  // 10미터 이상 움직였을 때 업데이트
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation(completion: @escaping (Result<CLLocation, Error>) -> Void) {
        // 기존 콜백 제거
        if currentLocationCompletion != nil {
            currentLocationCompletion = nil
        }
        
        // 권한 확인
        if authorizationStatus == .denied || authorizationStatus == .restricted {
            completion(.failure(LocationError.permissionDenied))
            return
        }
        
        currentLocationCompletion = completion
        locationManager.requestLocation()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func getAddressFromCoordinates(latitude: Double, longitude: Double, completion: @escaping (Result<String, Error>) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let placemark = placemarks?.first else {
                completion(.failure(LocationError.geocodingFailed))
                return
            }
            
            var addressComponents: [String] = []
            
            if let thoroughfare = placemark.thoroughfare {
                addressComponents.append(thoroughfare)
            }
            
            if let subThoroughfare = placemark.subThoroughfare {
                addressComponents.append(subThoroughfare)
            }
            
            if let locality = placemark.locality {
                addressComponents.append(locality)
            }
            
            if let subLocality = placemark.subLocality {
                addressComponents.append(subLocality)
            }
            
            if let administrativeArea = placemark.administrativeArea {
                addressComponents.append(administrativeArea)
            }
            
            if let postalCode = placemark.postalCode {
                addressComponents.append(postalCode)
            }
            
            if let country = placemark.country {
                addressComponents.append(country)
            }
            
            let address = addressComponents.joined(separator: " ")
            completion(.success(address))
        }
    }
    
    func getCoordinatesFromAddress(address: String, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let placemark = placemarks?.first, let location = placemark.location else {
                completion(.failure(LocationError.geocodingFailed))
                return
            }
            
            completion(.success(location.coordinate))
        }
    }
    
    func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        
        return fromLocation.distance(from: toLocation)
    }
    
    func getRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, completion: @escaping (Result<[CLLocationCoordinate2D], Error>) -> Void) {
        // 실제 환경에서는 MapKit의 MKDirections 또는 외부 API(Google Maps, Naver Maps 등)를 사용할 것
        // 여기서는 간단히 출발점과 도착점만 포함한 배열을 반환하는 것으로 대체한다.
        
        let coordinates = [from, to]
        completion(.success(coordinates))
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // 일회성 요청 처리
        if let completion = currentLocationCompletion {
            currentLocationCompletion = nil
            completion(.success(location))
        }
        
        // 델리게이트에 통지
        delegate?.locationService(self, didUpdateLocation: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // 일회성 요청 처리
        if let completion = currentLocationCompletion {
            currentLocationCompletion = nil
            completion(.failure(error))
        }
        
        // 델리게이트에 통지
        delegate?.locationService(self, didFailWithError: error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        delegate?.locationService(self, didChangeAuthorizationStatus: status)
    }
    
    // iOS 14 이전 버전 지원
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        delegate?.locationService(self, didChangeAuthorizationStatus: status)
    }
}

// MARK: - 오류 정의
enum LocationError: Error {
    case permissionDenied
    case locationUnknown
    case geocodingFailed
    case networkError
    case timeout
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .permissionDenied:
            return "위치 권한이 허용되지 않았습니다. 설정에서 위치 권한을 허용해주세요."
        case .locationUnknown:
            return "현재 위치를 확인할 수 없습니다."
        case .geocodingFailed:
            return "주소 변환에 실패했습니다."
        case .networkError:
            return "네트워크 연결을 확인해주세요."
        case .timeout:
            return "요청 시간이 초과되었습니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}