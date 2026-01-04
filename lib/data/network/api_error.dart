class ApiError implements Exception {
  final String message;
  final Map<String, List<String>>? fieldErrors;

  ApiError({
    required this.message,
    this.fieldErrors,
  });

  factory ApiError.fromDio(dynamic error) {
    final response = error.response;

    if (response != null && response.statusCode == 422) {
      final raw = response.data['errors'] as Map<String, dynamic>;

      return ApiError(
        message: 'Please correct the highlighted errors',
        fieldErrors: raw.map(
          (k, v) => MapEntry(k, List<String>.from(v)),
        ),
      );
    }

    if (response != null && response.statusCode == 401) {
      return ApiError(message: 'Invalid credentials');
    }

    return ApiError(
      message: 'Network or server error. Please try again.',
    );
  }

  @override
  String toString() => message;
}
