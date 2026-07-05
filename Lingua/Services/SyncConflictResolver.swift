import Foundation

struct PhraseSyncRecord: Equatable {
    var sourceText: String
    var translatedText: String
    var sourceLanguageCode: String
    var targetLanguageCode: String
    var updatedAt: Date
    var isFavorite: Bool
    var categoryNames: Set<String>
}

enum SyncConflictResolver {
    static func merge(local: PhraseSyncRecord, remote: PhraseSyncRecord) -> PhraseSyncRecord {
        let newestTimestamp = max(local.updatedAt, remote.updatedAt)
        let winningRecord = local.updatedAt >= remote.updatedAt ? local : remote

        return PhraseSyncRecord(
            sourceText: winningRecord.sourceText,
            translatedText: winningRecord.translatedText,
            sourceLanguageCode: winningRecord.sourceLanguageCode,
            targetLanguageCode: winningRecord.targetLanguageCode,
            updatedAt: newestTimestamp,
            isFavorite: local.isFavorite || remote.isFavorite,
            categoryNames: local.categoryNames.union(remote.categoryNames)
        )
    }
}
