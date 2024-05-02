import Foundation
import TonSwift

struct ExportDeeplinkGenerator {
  func generateDeeplink(network: Network, key: WalletKey) -> URL? {
    guard let publicKey = key
      .publicKey.data.base64EncodedString()
      .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?
      .replacingOccurrences(of: "+", with: "%2B") else {
      return nil
    }
    
    var components = URLComponents()
    components.scheme = "tonkeeper"
    components.host = "signer"
    components.path = "/link"
    components.percentEncodedQueryItems = [
      URLQueryItem(name: "pk", value: publicKey),
      URLQueryItem(name: "name", value: key.name),
      URLQueryItem(name: "network", value: network.rawValue)
    ]
    return components.url
  }
}

enum Network: String {
  case ton
}
