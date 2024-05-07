import 'package:equatable/equatable.dart';

class Success extends Equatable {
  final String message;

  const Success({this.message = "Success"});

  @override
  List<Object> get props => [message];
}
