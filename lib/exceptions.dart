class ApiException implements Exception {
  const ApiException({
    this.code,
    this.message,
  });

  final String? code;
  final String? message;

  static ApiException fromJson(Map<String, dynamic> data) {
    return ApiException(
        code: data['code'] ?? null, message: data['message'] ?? null);
  }

  String toString() {
    if (this.code == null) {
      return "Exception";
    }

    return "${this.code}: ${this.message}";
  }
}
