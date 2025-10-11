import Foundation
#if canImport(CryptoKit)
import CryptoKit
#else
import CommonCrypto
#endif

public enum Checksum {
    public static func sha256(for fileURL: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: fileURL)
        defer { try? handle.close() }
#if canImport(CryptoKit)
        var hasher = SHA256()
        while autoreleasepool(invoking: {
            let data = handle.readData(ofLength: 1024 * 512)
            if data.isEmpty { return false }
            hasher.update(data: data)
            return true
        }) {}
        let digest = hasher.finalize()
        return digest.map { String(format: "%02x", $0) }.joined()
#else
        let data = handle.readDataToEndOfFile()
        return sha256Fallback(data: data)
#endif
    }

#if !canImport(CryptoKit)
    private static func sha256Fallback(data: Data) -> String {
        var context = CC_SHA256_CTX()
        CC_SHA256_Init(&context)
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256_Update(&context, buffer.baseAddress, CC_LONG(buffer.count))
        }
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256_Final(&digest, &context)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
#endif
}
