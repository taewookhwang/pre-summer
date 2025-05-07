import Foundation
import CoreLocation

protocol LocationServiceProtocol {
    // 위치 권한 상태 확인
    var authorizationStatus: CLAuthorizationStatus { get }
    
    // 위치 업데이트 델리게이트
    var delegate: LocationServiceDelegate? { get set }
    
    // 권한 요청
    func requestAuthorization()
    
    // 현재 위치 가져오기(일회성)
    func getCurrentLocation(completion: @escaping (Result<CLLocation, Error>) -> Void)
    
    // 지속적 위치 업데이트 시작
    func startUpdatingLocation()
    
    // 위치 업데이트 중지
    func stopUpdatingLocation()
    
    // 좌표로 주소 가져오기(역지오코딩)
    func getAddressFromCoordinates(latitude: Double, longitude: Double, completion: @escaping (Result<String, Error>) -> Void)
    
    // 주소로 좌표 가져오기(지오코딩)
    func getCoordinatesFromAddress(address: String, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void)
    
    // 두 위치 간의 거리 계산
    func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance
    
    // 경로 가져오기(출발-도착)
    func getRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, completion: @escaping (Result<[CLLocationCoordinate2D], Error>) -> Void)
}

protocol LocationServiceDelegate: AnyObject {
    // 위치 업데이트 수신
    func locationService(_ service: LocationServiceProtocol, didUpdateLocation location: CLLocation)
    
    // 위치 권한 상태 변경 시
    func locationService(_ service: LocationServiceProtocol, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    
    // 오류 발생
    func locationService(_ service: LocationServiceProtocol, didFailWithError error: Error)
}