import Foundation

// These will be replaced with Box/Either or something native to Swift (fingers crossed) https://github.com/bignerdranch/CoreDataStack/issues/10

// MARK: - Operation Result Types

/// Result containing either an instance of `NSPersistentStoreCoordinator` or `ErrorType`
public enum CoordinatorResult {
    /// A success case with associated `NSPersistentStoreCoordinator` instance
    case success(NSPersistentStoreCoordinator)
    /// A failure case with associated `ErrorType` instance
    case failure(Swift.Error)
}
/// Result containing either an instance of `NSManagedObjectContext` or `ErrorType`
public enum BatchContextResult {
    /// A success case with associated `NSManagedObjectContext` instance
    case success(NSManagedObjectContext)
    /// A failure case with associated `ErrorType` instance
    case failure(Swift.Error)
}
/// Result of void representing `success` or an instance of `ErrorType`
public enum SuccessResult {
    /// A success case
    case success
    /// A failure case with associated ErrorType instance
    case failure(Swift.Error)
}
public typealias SaveResult = SuccessResult
public typealias ResetResult = SuccessResult
