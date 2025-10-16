import Foundation
import UIKit
import SnapKit
import KakaoMapsSDK
import CoreLocation

class MapViewController: UIViewController, MapControllerDelegate {

    
    var mapView: KMViewContainer!
    var controller: KMController?
    var locationManager: CLLocationManager!
    var lastCoordinate: CLLocationCoordinate2D?
    var mapReady = false
    var userPoiAdded = false // 현위치 마커 플래그
    var didCenterOnUser = false // 자동 축소 방지
    var userPoi: Poi?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        mapView = KMViewContainer(frame: view.bounds)
        view.addSubview(mapView)
        
        controller = KMController(viewContainer: mapView)
        controller?.delegate = self
        controller?.prepareEngine()
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        
       

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        controller?.activateEngine()
    }
    
    // 화면 떠날 땐 일시정지
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        controller?.pauseEngine()
    }
    
    // 리소스 해제
    deinit {
        controller?.pauseEngine()
        controller?.resetEngine()
    }
    
    func addViews() {
        // 위도, 경도
        let defaultPosition = MapPoint(longitude: 127.108678, latitude: 37.402001)
        let mapviewInfo = MapviewInfo(
            viewName: "mapView",
            viewInfoName: "map",
            defaultPosition: defaultPosition,
            defaultLevel: 17
        )
        controller?.addView(mapviewInfo)
    }
    
    //addView 성공 이벤트 delegate. 추가적으로 수행할 작업을 진행한다.
    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        print("OK") //추가 성공. 성공시 추가적으로 수행할 작업을 진행한다.
        mapReady = true
        guard let _ = controller?.getView("mapView") as? KakaoMap else { return }

        registerPerLevelStyle()
        createLabelLayer()
        //createPois()
        
        if let coord = lastCoordinate {
            moveCameraToCurrentLoaction(coord)
        }
        
        
      
    }

    //addView 실패 이벤트 delegate. 실패에 대한 오류 처리를 진행한다.
    func addViewFailed(_ viewName: String, viewInfoName: String) {
        print("Failed")
    }
    
    /* ---------- 사이즈(레이아웃) 반영 ---------- */
    func containerDidResized(_ size: CGSize) {
        guard let mapView = controller?.getView("mapView") as? KakaoMap else { return }
        mapView.viewRect = CGRect(origin: .zero, size: size)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = view.bounds
        if let kakaoMap = controller?.getView("mapView") as? KakaoMap {
            kakaoMap.viewRect = mapView.bounds
        }
    }
    
    func getKoreanAddress(la: Double, lo: Double) {
        let location = CLLocation(latitude: la, longitude: lo)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "ko_KR")) { (placemarks, error) in
            if let error = error {
                print("주소 변환 실패: \(error)")
                return
            }
            
            if let place = placemarks?.first {
                print(place.name ?? "주소 없음")
            }
        }
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    func getLocationUsagePermission() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("GPS 권한 설정됨")
        case .restricted, .notDetermined:
            print("GPS 권한 설정되지 않음")
            getLocationUsagePermission()
        case .denied:
            print("GPS 권한 요청 거부됨")
            getLocationUsagePermission()
        default:
            print("GPS: Default")
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("위치 정보를 가져오는 데 실패했습니다: \(error.localizedDescription)")
    }
  
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coord = location.coordinate
        
        lastCoordinate = coord
        if mapReady {
            moveCameraToCurrentLoaction(coord)
            
            if !didCenterOnUser {
                moveCameraToCurrentLoaction(coord)
                didCenterOnUser = true
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.createPois()
            }
        }
        
        getKoreanAddress(la: coord.latitude, lo: coord.longitude)
        
    }
    
    /* ---------- 마커 ----------*/
  
    func createLabelLayer() {
        let view = controller?.getView("mapView") as! KakaoMap
        let manager = view.getLabelManager()
        let layerOption = LabelLayerOptions(layerID: "PoiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 0)
        let _ = manager.addLabelLayer(option: layerOption)
    }
    
    func registerPerLevelStyle() {
        guard let map = controller?.getView("mapView") as? KakaoMap else { return }
        let manager = map.getLabelManager()
        
        let iconImage = (UIImage(named: "marker_small") ?? UIImage(systemName: "mappin")!).withRenderingMode(.alwaysOriginal)
        let icon = PoiIconStyle(symbol: iconImage, anchorPoint: CGPoint(x: 0.5, y: 1.0))
        
        var styles: [PerLevelPoiStyle] = []
        for level in 0...20 {
            styles.append(PerLevelPoiStyle(iconStyle: icon, level: level))
        }
        
        let poiStyle = PoiStyle(styleID: "PerLevelStyle", styles: styles)
        manager.addPoiStyle(poiStyle)
    }
    
    func createPois() {
        let view = controller?.getView("mapView") as! KakaoMap
        let manager = view.getLabelManager()
        let layer = manager.getLabelLayer(layerID: "PoiLayer")

        guard let coord = lastCoordinate else { return }
        let point = MapPoint(longitude: coord.longitude, latitude: coord.latitude)
   
        if let poi = userPoi {
            poi.position = point
                poi.show()
                return
        }
        
        let poiOption = PoiOptions(styleID: "PerLevelStyle")
        poiOption.rank = 0
        
        
        let poi1 = layer?.addPoi(option: poiOption, at: point)
        poi1?.show()
        
        //view.moveCamera(CameraUpdate.make(target: point, zoomLevel: 15, mapView: view))
    }
    
    // 현위치로 이동
    func moveCameraToCurrentLoaction(_ coordinate: CLLocationCoordinate2D) {
        let currentPosition = MapPoint(longitude: coordinate.longitude, latitude: coordinate.latitude)
        
        if let mapView = controller?.getView("mapView") as? KakaoMap {
            mapView.moveCamera(CameraUpdate.make(target: currentPosition, zoomLevel: 15, mapView: mapView))
        }
    }
    
}


