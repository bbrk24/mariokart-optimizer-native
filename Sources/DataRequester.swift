import Foundation
import Alamofire

struct HttpResponse: Sendable {
    var statusCode: Int
    var headers: HTTPHeaders
    var body: Data?
}

struct DataRequester: Sendable {
    var session = AF

    static let headerDateFormatter: DateFormatter = {
        let formatter = DateFormatter()

        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = .gmt
        formatter.calendar = Calendar(identifier: .gregorian)

        formatter.dateFormat = "EEE, dd MMM yyyy HH':'mm':'ss 'GMT'"

        return formatter
    }()

    func getData(
        url: some URLConvertible,
        accept: String,
        ifModifiedSince: Date?
    ) async -> AFDataResponse<Data> {
        var headers = HTTPHeaders(["Accept": accept])

        if let ifModifiedSince {
            headers.add(
                name: "If-Modified-Since",
                value: DataRequester.headerDateFormatter.string(from: ifModifiedSince)
            )
        }

        #if DEBUG
            print("GET \(url)\n\(headers)\n")
        #endif

        let response =
            await session
            .request(url, headers: headers)
            .serializingData(emptyResponseCodes: [304])
            .response

        return response
    }
}
