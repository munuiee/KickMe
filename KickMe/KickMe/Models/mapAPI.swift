// 지도 API 전용 파일입니다

import Foundation

// 전체 응답
struct KakaoAddressResponse: Codable {
    let documents: [KakaoDocument]
    let meta: KakaoMeta
}


// 주소 결과 - 검색된 1개의 모든 정보 (지번/도로명/좌표 포함)
struct KakaoDocument: Codable {
    let address: KakaoAddress?
    let addressName, addressType: String
    let roadAddress: KakaoRoadAddress?
    let x, y: String // x: 경도, y: 위도
    
    enum CodingKeys: String, CodingKey {
        case address
        case addressName = "address_name"
        case addressType = "address_type"
        case roadAddress = "road_address"
        case x, y
    }
}


// 지번 주소 - 행정동 기반의 주소 정보 (행정구역 단위, 번지수 포함)
struct KakaoAddress: Codable {
    let addressName, bCode, hCode, mainAddressNo: String
    let mountainYn, region1DepthName, region2DepthName, region3DepthHName: String
    let region3DepthName, subAddressNo, x, y: String
    
    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
        case bCode = "b_code"
        case hCode = "h_code"
        case mainAddressNo = "main_address_no"
        case mountainYn = "mountain_yn"
        case region1DepthName = "region_1depth_name"
        case region2DepthName = "region_2depth_name"
        case region3DepthHName = "region_3depth_h_name"
        case region3DepthName = "region_3depth_name"
        case subAddressNo = "sub_address_no"
        case x, y
    }
}


// 도로명 주소 - 도로명 기반의 주소 정보 (건물명, 도로명, 우편번호 등)
struct KakaoRoadAddress: Codable {
    let addressName, buildingName, mainBuildingNo, region1DepthName: String
    let region2DepthName, region3DepthName, roadName, subBuildingNo: String
    let undergroundYn, x, y, zoneNo: String
    
    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
        case buildingName = "building_name"
        case mainBuildingNo = "main_building_no"
        case region1DepthName = "region_1depth_name"
        case region2DepthName = "region_2depth_name"
        case region3DepthName = "region_3depth_name"
        case roadName = "road_name"
        case subBuildingNo = "sub_building_no"
        case undergroundYn = "underground_yn"
        case x, y
        case zoneNo = "zone_no"
    }
}


// 메타데이터 - 검색 결과에 대한 요약 정보
struct KakaoMeta: Codable {
    let isEnd: Bool // 다음 페이지 여부
    let pageableCount, totalCount: Int // 한 번에 받을 수 있는 결과 개수 / 전체 검색 결과 개수
    
    enum CodingKeys: String, CodingKey {
        case isEnd = "is_end"
        case pageableCount = "pageable_count"
        case totalCount = "total_count"
    }
}
