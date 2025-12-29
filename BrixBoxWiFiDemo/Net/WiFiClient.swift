import Foundation
import Combine

final class WiFiClient: ObservableObject {
    @Published var statusText: String = "WiFi: idle"
    @Published var latest: BrixResponse?
    @Published var lastError: String?

    func fetch(urlString: String) async {
        guard let url = URL(string: urlString) else {
            await MainActor.run {
                self.lastError = "Bad URL"
                self.statusText = "WiFi: bad url"
            }
            return
        }

        do {
            await MainActor.run { self.statusText = "WiFi: fetching…" }
            let (data, resp) = try await URLSession.shared.data(from: url)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
                throw NSError(domain: "HTTP", code: 1)
            }
            let decoded = try JSONDecoder().decode(BrixResponse.self, from: data)
            await MainActor.run {
                self.latest = decoded
                self.lastError = nil
                self.statusText = "WiFi: ok"
            }
        } catch {
            await MainActor.run {
                self.lastError = error.localizedDescription
                self.statusText = "WiFi: error"
            }
        }
    }
}
