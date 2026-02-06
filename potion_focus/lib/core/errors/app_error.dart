/// Structured error types for user-friendly error messages.
/// Each error has a code, title, message, and optional suggestion.
class AppError {
  final String code;
  final String title;
  final String message;
  final String? suggestion;

  const AppError({
    required this.code,
    required this.title,
    required this.message,
    this.suggestion,
  });

  @override
  String toString() => '$code: $title - $message';
}

/// Predefined error types for common scenarios
class AppErrors {
  AppErrors._();

  // Shop Errors
  static AppError insufficientEssence(int needed, int current) => AppError(
        code: 'INSUFFICIENT_ESSENCE',
        title: 'Not Enough Essence',
        message: 'You need ${needed - current} more essence to purchase this item.',
        suggestion: 'Keep brewing to earn more!',
      );

  static AppError insufficientCoins(int needed, int current) => AppError(
        code: 'INSUFFICIENT_COINS',
        title: 'Not Enough Coins',
        message: 'You need ${needed - current} more coins to purchase this item.',
        suggestion: 'Coins can be purchased in the store.',
      );

  static const AppError itemAlreadyOwned = AppError(
    code: 'ITEM_ALREADY_OWNED',
    title: 'Already Owned',
    message: 'This item is already in your collection.',
  );

  static const AppError itemNotFound = AppError(
    code: 'ITEM_NOT_FOUND',
    title: 'Item Unavailable',
    message: 'This item is no longer available.',
  );

  // Quest Errors
  static const AppError questAlreadyComplete = AppError(
    code: 'QUEST_ALREADY_COMPLETE',
    title: 'Quest Complete',
    message: 'This quest has already been completed.',
  );

  static const AppError questExpired = AppError(
    code: 'QUEST_EXPIRED',
    title: 'Quest Expired',
    message: 'This quest is no longer active.',
  );

  // Session Errors
  static const AppError sessionInProgress = AppError(
    code: 'SESSION_IN_PROGRESS',
    title: 'Session Active',
    message: 'A brewing session is already in progress.',
  );

  static const AppError noTagsSelected = AppError(
    code: 'NO_TAGS_SELECTED',
    title: 'No Tags Selected',
    message: 'Please select at least one tag before starting.',
    suggestion: 'Tags help categorize your focus sessions.',
  );

  static AppError tagLimitReached(int limit) => AppError(
        code: 'TAG_LIMIT_REACHED',
        title: 'Tag Limit Reached',
        message: 'You can only select up to $limit tags per session.',
      );

  // Network Errors
  static const AppError networkError = AppError(
    code: 'NETWORK_ERROR',
    title: 'Connection Error',
    message: 'Unable to connect. Please check your internet connection.',
    suggestion: 'Your data is saved locally and will sync when online.',
  );

  // Generic Errors
  static const AppError unknownError = AppError(
    code: 'UNKNOWN_ERROR',
    title: 'Something Went Wrong',
    message: 'An unexpected error occurred.',
    suggestion: 'Please try again.',
  );
}

/// Result type that can hold either a success value or an AppError
class Result<T> {
  final T? value;
  final AppError? error;

  const Result.success(this.value) : error = null;
  const Result.failure(this.error) : value = null;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;

  /// Execute callback on success
  Result<T> onSuccess(void Function(T value) callback) {
    if (isSuccess && value != null) {
      callback(value as T);
    }
    return this;
  }

  /// Execute callback on failure
  Result<T> onFailure(void Function(AppError error) callback) {
    if (isFailure && error != null) {
      callback(error!);
    }
    return this;
  }
}
