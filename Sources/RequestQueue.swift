actor RequestQueue<
    Id: Hashable & Sendable,
    Result: Sendable,
    Failure: Error
> {
    private var requests: [Id: Task<Result, Error>] = [:]

    func addOrWait(
        id: Id,
        body: @Sendable @escaping () async throws(Failure) -> Result
    ) async throws(Failure) -> Result {
        if let task = requests[id] {
            do {
                return try await task.value
            } catch {
                throw error as! Failure
            }
        }

        let task = Task {
            defer { requests.removeValue(forKey: id) }
            return try await body()
        }
        requests[id] = task

        do {
            return try await task.value
        } catch {
            throw error as! Failure
        }
    }
}
