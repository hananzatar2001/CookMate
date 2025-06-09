// server.dart
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

final _meals = [
  {"title": "Salad with eggs", "kcal": 294, "weight": "100g"},
  {"title": "Salad with eggs", "kcal": 294, "weight": "100g"},
  {"title": "Salad with eggs", "kcal": 294, "weight": "100g"},
];

Response _handler(Request request) {
  if (request.url.path == 'meals') {
    return Response.ok(jsonEncode(_meals), headers: {'Content-Type': 'application/json'});
  }
  return Response.notFound('Not Found');
}

void main() async {
  final handler = const Pipeline().addMiddleware(logRequests()).addHandler(_handler);
  final server = await io.serve(handler, InternetAddress.anyIPv4, 8080);
  print('Server listening on port ${server.port}');
}
