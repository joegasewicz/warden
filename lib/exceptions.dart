class ProcessingCompileException extends Error {
  final String message = "Error processing dart compile cmd";

  @override
  String toString() => "ProcessingError: $message";
}
