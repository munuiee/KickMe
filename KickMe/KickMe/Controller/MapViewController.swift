import Foundation
import UIKit
import SnapKit
import KakaoMapsSDK
import CoreLocation

final class MapViewController: UIViewController {
    
    
    private let myLocation = UIButton()
    private let search = UITextField()
    private let iconImage = UIImageView()
    
    private enum KickMode { case user, search }
    private var kickMode: KickMode = .user
    
    
    
    private var mapView: KMViewContainer!
    private var controller: KMController?
    private var locationManager: CLLocationManager!
    private var lastCoordinate: CLLocationCoordinate2D? {
        didSet {
            guard mapReady, let c = lastCoordinate else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                switch self.kickMode {
                case .user:
                    self.showKickboards(around: c, layerID: self.userKickLayerID, moveCamera: false)
                case .search:
                    break
                }
            }
        }
    }
    private var mapReady = false
    private var userPoiAdded = false // 현위치 마커 플래그
    private var didCenterOnUser = false // 자동 축소 방지
    private var userPoi: Poi?
    
    private let geocoder = CLGeocoder()
    private var searchPoi: Poi?
    
    private let kickLayerID = "KickLayer"
    private var kickboardStyle = false // 킥보드 스타일 플래그
    private var kickPOIs: [Poi] = []
    
    private var pendingKickCenter: CLLocationCoordinate2D?
    
    // 현재 표시 중인 킥보드 POI들의 ID 추적
    private var kickPoiIDs: [String] = []
    private var lastPlacementKey: String?
    private var isPlacingKicks = false
    private var lastKickKey: String?
    private var lastKickCoords: [CLLocationCoordinate2D] = []
    
    private var kickPoiIDsByLayer: [String: Set<String>] = [:]
    
    private var userKickLayerID = "UserKickLayer"
    private var searchKickLayerID = "SearchKickLayer"
    
    private var lastKickKeyByLayer: [String: String] = [:]
    private var lastKickCoordsByLayer: [String: [CLLocationCoordinate2D]] = [:]
    
    // 레이어를 지운 적이 있음을 표시하는 플래그
    private var removedLayers = Set<String>()
    
    
    
    private let kakao = KakaoLocalAPI(apiKey: SecretLoader.kakaoREST())
    
    
    
    
    
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
        
        configureUI()
        hideKeyboard()
        
        
        
        
        
    }
    
    
    /* --------- UI ---------- */
    func configureUI() {
        [myLocation, search]
            .forEach{ view.addSubview($0) }
        
        // 현위치 버튼 UI
        myLocation.layer.cornerRadius = 25
        myLocation.setImage(UIImage(named: "currentPin"), for: .normal)
        myLocation.imageView?.contentMode = .scaleAspectFit
        
        
        myLocation.backgroundColor = .white
        myLocation.layer.shadowOpacity = 0.3
        myLocation.layer.shadowOffset = CGSize(width: 0, height: 3)
        myLocation.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        
        
        myLocation.snp.makeConstraints {
            $0.width.height.equalTo(50)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().inset(100)
        }
        
        // 검색창 UI
        search.layer.cornerRadius = 10
        search.backgroundColor = .white
        search.layer.borderColor = UIColor.black.cgColor
        search.layer.borderWidth = 1
        search.translatesAutoresizingMaskIntoConstraints = false
        search.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 0))
        search.leftViewMode = .always
        search.placeholder = "주소를 입력해주세요."
        search.clearButtonMode = .always
        search.returnKeyType = .search
        search.addTarget(self, action: #selector(onSearchReturn(_:)), for: .editingDidEndOnExit)
        
        
        search.snp.makeConstraints {
            $0.width.equalTo(400)
            $0.height.equalTo(40)
            $0.top.equalToSuperview().inset(100)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        // 검색 아이콘
        search.addSubview(iconImage)
        iconImage.image = UIImage(systemName: "magnifyingglass")
        iconImage.tintColor = UIColor(named: "mainColor")
        iconImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(10)
            $0.width.height.equalTo(20)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        controller?.activateEngine()
    }
    
    //    override func viewDidAppear(_ animated: Bool) {
    //        super.viewDidAppear(animated)
    //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    //            self.mapReady = true
    //            if let c = self.lastCoordinate {
    //                self.showKickboards(around: c)
    //            }
    //        }
    //    }
    
    
    
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
            moveCameraToCurrentLocation(coord)
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
    
    @objc private func buttonClicked() {
        print("버튼 클릭됨!")
        guard let coordinate = locationManager.location?.coordinate else {
            print("위치 정보를 아직 못 받았어요 😢")
            return
        }
        moveCameraToCurrentLocation(coordinate)
        
        kickMode = .user
        hideKickboards(layerID: searchKickLayerID)
        showKickboards(around: coordinate, layerID: userKickLayerID, moveCamera: true)
    }
    
    
    
    
    /* ---------- 주소 검색시 이동 ---------- */
    func addPinForAddress(_ address: String) {
        kakao.geocode(address) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let coord):
                    self?.didCenterOnUser = true
                    self?.dropSearchPinAndGo(to: coord, title: address)
                case .failure(let e):
                    print("카카오 주소 검색 실패:", e.localizedDescription)
                }
            }
        }
    }
    
    func dropSearchPinAndGo(to coord: CLLocationCoordinate2D, title: String) {
        guard let map = controller?.getView("mapView") as? KakaoMap else { return }
        let manager = map.getLabelManager()
        guard let layer = manager.getLabelLayer(layerID: "PoiLayer") else { return }
        
        let point = MapPoint(longitude: coord.longitude, latitude: coord.latitude)
        
        if let poi = searchPoi {
            poi.position = point
            poi.show()
        } else {
            let opt = PoiOptions(styleID: "PerLevelStyle")
            opt.rank = 0
            searchPoi = layer.addPoi(option: opt, at: point)
            searchPoi?.show()
        }
        
        moveCameraToCurrentLocation(coord)
        lastCoordinate = coord
        kickMode = .search
        hideKickboards(layerID: userKickLayerID)
        showKickboardsAroundSearchLocation(coord)
        
    }
    
    @objc func onSearchReturn(_ tf: UITextField) {
        guard let q = tf.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !q.isEmpty else { return }
        addPinForAddress(q)
        print("RETURN!")
    }
    
    /* ---------- 🛴 킥보드 마커 띄우기 ---------- */
    private func placementKey(for coord: CLLocationCoordinate2D) -> String {
        // 약 100m 그리드로 라운딩해서 같은 구역이면 같은 키를 만들기
        let metersPerDegLat: Double = 111_320
        let metersPerDegLon: Double = metersPerDegLat * cos(coord.latitude * .pi / 180)
        
        func roundTo100m(_ meters: Double) -> Double { (meters / 100.0).rounded() * 100.0 }
        
        let x = roundTo100m(coord.latitude * metersPerDegLat)
        let y = roundTo100m(coord.longitude * metersPerDegLon)
        return "\(x)-\(y)"
    }
    
    
    func requestShowKickboards(around center: CLLocationCoordinate2D, isSearch: Bool) {
        lastCoordinate = center
        if mapReady {
            if isSearch {
                showKickboardsAroundSearchLocation(center)
            } else {
                showKickboardsAroundUser(center)
            }
        } else {
            pendingKickCenter = center          // 준비 전이면 잠깐 보관
        }
    }
    
    
    private func kickStyle(on map: KakaoMap) {
        
        if self.kickboardStyle { return }
        
        let manager = map.getLabelManager()
        
        guard let iconImage = (UIImage(named: "marker_small") ?? UIImage(systemName: "mappin.circle")?.withRenderingMode(.alwaysOriginal)) else { return }
        // guard let iconImage else { return }
        
        let icon = PoiIconStyle(symbol: iconImage, anchorPoint: CGPoint(x: 0.5, y: 1.0))
        
        var _: [PerLevelPoiStyle] = (1...20).map {
            PerLevelPoiStyle(iconStyle: icon, level: $0)
        }
        
        let poiStyle = PoiStyle(
            styleID: "kickboardStyle",
            styles: (0...20).map { PerLevelPoiStyle(iconStyle: icon, level: $0)}
        )
        
        
        manager.addPoiStyle(poiStyle)
        
        self.kickboardStyle = true
    }
    
    func didTapKickPoi(_ param: PoiInteractionEventParam) {
        let poi = param.poiItem
        print("킥보드 탭됨 poiID=\(poi.itemID)")
        let registerVC = RegisterViewController()
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    
    
    private func ensureKickLayer(on map: KakaoMap, layerID: String) -> KakaoMapsSDK.LabelLayer? {
        let manager = map.getLabelManager()
        if let layer = manager.getLabelLayer(layerID: layerID) {
            layer.visible = true
            return layer
        }
        let opt = LabelLayerOptions(
            layerID: layerID,
            competitionType: .none,
            competitionUnit: .symbolFirst,
            orderType: .rank,
            zOrder: 999
        )
        
        _ = manager.addLabelLayer(option: opt)
        let layer = manager.getLabelLayer(layerID: layerID)
        layer?.visible = true
        return layer
        
    }
    
    
    private func clearKickboards(from layer: KakaoMapsSDK.LabelLayer, layerID: String) {
        let ids = kickPoiIDsByLayer[layerID] ?? []
        for id in ids {
            layer.removePoi(poiID: id)
        }
        kickPoiIDsByLayer[layerID] = []
    }
    
    
    
    private func kickLocation(_ center: CLLocationCoordinate2D,
                              radiusM: Double = 50,
                              count: Int = 3) -> [CLLocationCoordinate2D] {
        let metersPerDegLat: Double = 111_320 // 위도 1도 차이
        let metersPerDegLon: Double = metersPerDegLat * cos(center.latitude * .pi / 180)
        
        var results: [CLLocationCoordinate2D] = []
        for _ in 0..<count {
            let theta = Double.random(in: 0..<(2 * .pi)) // 중심에서 뻗어나가는 방향 각도
            let r = sqrt(Double.random(in: 0...1)) * radiusM // 중심~점까지의 거리. 가장자리로만 몰리는 것 방지
            
            let dLat = (r * sin(theta)) / metersPerDegLat
            let dLon = (r * cos(theta)) / metersPerDegLon
            
            results.append(.init(latitude: center.latitude + dLat,
                                 longitude: center.longitude + dLon))
        }
        return results
    }
    
    private func showKickboards(around center: CLLocationCoordinate2D, layerID: String = "UserKickLayer", moveCamera: Bool = false) {
        
        guard let map = controller?.getView("mapView") as? KakaoMap else { return }
        
        DispatchQueue.main.async {
            let target = MapPoint(longitude: center.longitude, latitude: center.latitude)
            if moveCamera {
                let target = MapPoint(longitude: center.longitude, latitude: center.latitude)
                map.moveCamera(CameraUpdate.make(target: target, zoomLevel: 17, mapView: map))
            }
            
            self.kickStyle(on: map)
            guard let layer = self.ensureKickLayer(on: map, layerID: layerID) else { return }
            
            
            let key = self.placementKey(for: center)
            
            if self.lastKickKeyByLayer[layerID] == key,
               let ids = self.kickPoiIDsByLayer[layerID],
               !ids.isEmpty,
               !self.removedLayers.contains(layerID) {
                return
            }
            
            self.clearKickboards(from: layer, layerID: layerID)
            // let coords = self.kickLocation(center, radiusM: 500,  count: 4)
            let coords: [CLLocationCoordinate2D]
            
            if self.lastKickKeyByLayer[layerID] == key,
               let cached = self.lastKickCoordsByLayer[layerID],
               !cached.isEmpty {
                coords = cached
            } else {
                let generated = self.kickLocation(center, radiusM: 500, count: 4)
                self.lastKickKeyByLayer[layerID] = key
                self.lastKickCoordsByLayer[layerID] = generated
                coords = generated
            }
            
            
            
            var ids = self.kickPoiIDsByLayer[layerID] ?? []
            for (idx, c) in coords.enumerated() {
                let point = MapPoint(longitude: c.longitude, latitude: c.latitude)
                let poiID = "\(layerID)-kick-\(key)-\(idx)"
                let option = PoiOptions(styleID: "kickboardStyle")
                option.rank = 10 + idx
                
                option.clickable = true
                
                
                if let poi = layer.addPoi(option: option, at: point) {
                    poi.show()
                    ids.insert(poiID)
                    _ = poi.addPoiTappedEventHandler(target: self, handler: MapViewController.didTapKickPoi)
                } else {
                    print("addPoi failed at idx \(idx)")
                }
            }
            self.kickPoiIDsByLayer[layerID] = ids
            self.removedLayers.remove(layerID)
            
            
        }
        
        
    }
    
    // ✅ 현위치 모드: 검색 레이어 숨기고, 현위치 레이어만 그림
    func showKickboardsAroundUser(_ coord: CLLocationCoordinate2D) {
        hideKickboards(layerID: searchKickLayerID)
        showKickboards(around: coord, layerID: userKickLayerID, moveCamera: false)
    }
    
    // ✅ 검색 모드: 현위치 레이어 숨기고, 검색 레이어만 그림
    func showKickboardsAroundSearchLocation(_ coord: CLLocationCoordinate2D) {
        hideKickboards(layerID: userKickLayerID)
        showKickboards(around: coord, layerID: searchKickLayerID, moveCamera: true)
    }
    
    
    private func hideKickboards(layerID: String) {
        guard let map = controller?.getView("mapView") as? KakaoMap else { return }
        let manager = map.getLabelManager()
        if manager.getLabelLayer(layerID: layerID) != nil {
            manager.removeLabelLayer(layerID: layerID)
        }
        removedLayers.insert(layerID)
    }
    
    
    
    
    
}








/* ---------- 카카오 맵 델리게이트 ---------- */

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
        
        
        if mapReady, !didCenterOnUser {
            moveCameraToCurrentLocation(coord)
            didCenterOnUser = true
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.createPois()
        }
        
        
        getKoreanAddress(la: coord.latitude, lo: coord.longitude)
        
    }
    
    
    
    
    // 마커(핀)
    func createLabelLayer() {
        guard let view = controller?.getView("mapView") as? KakaoMap else { return }
        let manager = view.getLabelManager()
        
        if manager.getLabelLayer(layerID: "PoiLayer") != nil { return }
        
        let layerOption = LabelLayerOptions(
            layerID: "PoiLayer",
            competitionType: .none,
            competitionUnit: .symbolFirst,
            orderType: .rank,
            zOrder: 0
        )
        _ = manager.addLabelLayer(option: layerOption)
    }
    
    func registerPerLevelStyle() {
        guard let map = controller?.getView("mapView") as? KakaoMap else { return }
        let manager = map.getLabelManager()
        
        let iconImage = (UIImage(named: "marker") ?? UIImage(systemName: "mappin")!).withRenderingMode(.alwaysOriginal)
        let icon = PoiIconStyle(symbol: iconImage, anchorPoint: CGPoint(x: 0.5, y: 1.0))
        
        
        
        var styles: [PerLevelPoiStyle] = []
        for level in 0...20 {
            styles.append(PerLevelPoiStyle(iconStyle: icon, level: level))
        }
        
        let poiStyle = PoiStyle(styleID: "PerLevelStyle", styles: styles)
        manager.addPoiStyle(poiStyle)
    }
    
    func createPois() {
        guard let view = controller?.getView("mapView") as? KakaoMap else { return }
        let manager = view.getLabelManager()
        guard let layer = manager.getLabelLayer(layerID: "PoiLayer") else { return }
        
        
        guard let coord = lastCoordinate else { return }
        let point = MapPoint(longitude: coord.longitude, latitude: coord.latitude)
        
        if let poi = userPoi {
            poi.position = point
            poi.show()
            return
        }
        
        let poiOption = PoiOptions(styleID: "PerLevelStyle")
        poiOption.rank = 0
        
        
        let poi = layer.addPoi(option: poiOption, at: point)
        poi?.show()
        userPoi = poi
        
    }
    
    
    
    // 현위치로 이동
    func moveCameraToCurrentLocation(_ coordinate: CLLocationCoordinate2D) {
        let currentPosition = MapPoint(longitude: coordinate.longitude, latitude: coordinate.latitude)
        
        if let mapView = controller?.getView("mapView") as? KakaoMap {
            mapView.moveCamera(CameraUpdate.make(target: currentPosition, zoomLevel: 15, mapView: mapView))
        }
    }
    
    
}

extension UIViewController {
    func hideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension MapViewController: MapControllerDelegate {
    func onMapReady(_ map: KakaoMap) {
        mapReady = true
        print("맵 준비 완료")
        if let c = pendingKickCenter {
            pendingKickCenter = nil
            showKickboards(around: c)
        }
    }
}


