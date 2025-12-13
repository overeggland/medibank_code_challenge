import Foundation
import OSLog

/// Logger class for API requests, data caching, and error status
enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.medibank.news"
    
    // MARK: - Background Queue for Logging
    private static let loggingQueue = DispatchQueue(
        label: "com.medibank.news.logging",
        qos: .utility,
        attributes: .concurrent
    )
    
    // MARK: - Log Categories
    private static let apiLogger = Logger(subsystem: subsystem, category: "API")
    private static let cacheLogger = Logger(subsystem: subsystem, category: "Cache")
    private static let errorLogger = Logger(subsystem: subsystem, category: "Error")
    
    // MARK: - API Request Logging
    static func logAPIRequest(url: URL, method: String = "GET") {
        #if DEBUG
        loggingQueue.async {
            apiLogger.info("🌐 API Request: \(method) \(url.absoluteString)")
        }
        #endif
    }
    
    static func logAPIResponse(url: URL, statusCode: Int, dataSize: Int? = nil) {
        #if DEBUG
        loggingQueue.async {
            if let dataSize {
                apiLogger.info("✅ API Response: \(statusCode) - \(url.absoluteString) [\(dataSize) bytes]")
            } else {
                apiLogger.info("✅ API Response: \(statusCode) - \(url.absoluteString)")
            }
        }
        #endif
    }
    
    static func logAPIError(url: URL, error: Error) {
        #if DEBUG
        loggingQueue.async {
            errorLogger.error("❌ API Error: \(url.absoluteString) - \(error.localizedDescription)")
        }
        #endif
    }
    
    static func logAPIError(url: URL, statusCode: Int) {
        #if DEBUG
        loggingQueue.async {
            errorLogger.error("❌ API Error: \(url.absoluteString) - HTTP \(statusCode)")
        }
        #endif
    }
    
    // MARK: - Data Caching Logging
    static func logCacheSave(key: String, itemCount: Int? = nil) {
        #if DEBUG
        loggingQueue.async {
            if let itemCount {
                cacheLogger.info("💾 Cache Save: \(key) - \(itemCount) items")
            } else {
                cacheLogger.info("💾 Cache Save: \(key)")
            }
        }
        #endif
    }
    
    static func logCacheLoad(key: String, itemCount: Int? = nil) {
        #if DEBUG
        loggingQueue.async {
            if let itemCount {
                cacheLogger.info("📂 Cache Load: \(key) - \(itemCount) items")
            } else {
                cacheLogger.info("📂 Cache Load: \(key)")
            }
        }
        #endif
    }
    
    static func logCacheMiss(key: String) {
        #if DEBUG
        loggingQueue.async {
            cacheLogger.debug("⚠️ Cache Miss: \(key)")
        }
        #endif
    }
    
    static func logCacheError(key: String, error: Error) {
        #if DEBUG
        loggingQueue.async {
            errorLogger.error("❌ Cache Error: \(key) - \(error.localizedDescription)")
        }
        #endif
    }
    
    // MARK: - General Error Logging
    static func logError(_ message: String, error: Error? = nil) {
        #if DEBUG
        loggingQueue.async {
            if let error {
                errorLogger.error("❌ Error: \(message) - \(error.localizedDescription)")
            } else {
                errorLogger.error("❌ Error: \(message)")
            }
        }
        #endif
    }
    
    static func logInfo(_ message: String) {
        #if DEBUG
        loggingQueue.async {
            apiLogger.info("ℹ️ \(message)")
        }
        #endif
    }
    
    static func logDebug(_ message: String) {
        #if DEBUG
        loggingQueue.async {
            apiLogger.debug("🔍 \(message)")
        }
        #endif
    }
}

