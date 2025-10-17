import Foundation
import CoreLocation


/* ---------- 에러타입 ---------- */
enum KakaoGeoError: Error, LocalizedError {
    case invalidURL
    case httpStatus(Int, String)
    case noResult
    case missingKey
    case convertFail
    
    var message: String? {
        switch self {
        case .invalidURL:
            return "잘못된 URL"
        case .httpStatus(let code, let body):
            return "HTTP \(code) 오류. 서버 응답: \(body)"
        case .noResult:
            return "검색 결과가 없음"
        case .missingKey:
            return "응답 또는 데이터가 비어있음"
        case .convertFail:
            return "좌표 변환 실패"
        }
    }
}



/* ---------- 비밀키 로더 ---------- */
enum SecretLoader {
    static func kakaoREST() -> String {
        guard
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let dict = NSDictionary(contentsOf: url),
            let key = dict["KAKAO_REST_API_KEY"] as? String
        else {
            print("Secrets.plist에서 키를 읽지 못함!")
            return ""
        }
        return key.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    static func kakaoAppKey() -> String {
        guard
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let dict = NSDictionary(contentsOf: url),
            let key = dict["KAKAO_APP_KEY"] as? String
        else {
            print("[SecretLoader] KAKAO_APP_KEY not found.")
            return ""
        }
        return key.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}


final class KakaoLocalAPI {
    // REST API키 보관
    private let apiKey: String
    init(apiKey: String) { self.apiKey = apiKey }
    
    
    // 주소(문자열)에서 좌표로 변환
    func geocode(_ query: String, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        
        guard var component = URLComponents(string: "https://dapi.kakao.com/v2/local/search/address.json") else {
            return completion(.failure(KakaoGeoError.invalidURL))
        }
        component.queryItems = [URLQueryItem(name: "query", value: query)]
        guard let _ = component.url else {
            return completion(.failure(KakaoGeoError.invalidURL))
        }
        
        var request = URLRequest(url: component.url!)
        request.httpMethod = "GET"
        request.setValue("KakaoAK \(apiKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("URLSession error:", error)
                return completion(.failure(error))
            }
            guard let http = response as? HTTPURLResponse, let data = data else {
                print("response/data nil")
                return completion(.failure(KakaoGeoError.missingKey))
            }
            
            let bodyString = String(data: data, encoding: .utf8) ?? ""
            print("status:", http.statusCode)
            print("body", bodyString)
            
            // 상태코드 체크
            guard (200...299).contains(http.statusCode) else {
                return completion(.failure(KakaoGeoError.httpStatus(http.statusCode, bodyString)))
            }
            
            do {
                //테스트용
                struct Mini: Decodable {
                    struct Doc: Decodable { let x: String; let y: String }
                    let documents: [Doc]
                }
                let decoded = try JSONDecoder().decode(KakaoAddressResponse.self, from: data)
                
                print("documents.count = ", decoded.documents.count)
                
                guard let first = decoded.documents.first else {
                    return completion(.failure(KakaoGeoError.noResult))
                }
                guard let lat = Double(first.y), let lon = Double(first.x) else {
                    return completion(.failure(KakaoGeoError.convertFail))
                }
                completion(.success(CLLocationCoordinate2D(latitude: lat, longitude: lon)))
            } catch {
                print("[Kakao] decode error:", error)
                print("[Kakao] raw body:", bodyString)
                completion(.failure(error))
            }
        }.resume()
        
        
    }
}
