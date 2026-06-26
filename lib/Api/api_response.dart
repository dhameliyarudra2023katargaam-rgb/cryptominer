class ApiResponse<T> {
  String? message;
  T? data;
  Status status;

  ApiResponse.initial({this.message}) : status = Status.INITIAL;

  ApiResponse.loading({this.message}) : status = Status.LOADING;

  ApiResponse.complete([this.data]) : status = Status.COMPLETE;

  ApiResponse.error({this.message}) : status = Status.ERROR;

  ApiResponse.success({this.message}) : status = Status.SUCCESS;

  String getString() {
    return 'Status : $status message : $message data : $data';
  }
}

// ignore: constant_identifier_names
enum Status { INITIAL, LOADING, COMPLETE, ERROR, SUCCESS }
