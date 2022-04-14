import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import '../exception/api_exception.dart';
import '../model/superhero.dart';

class SuperheroBloc {
  http.Client? client;
  final String id;

  final superheroSubject = BehaviorSubject<Superhero>();

  StreamSubscription? requestSubscription;

  SuperheroBloc({this.client, required this.id}) {
    requestSuperhero();
  }

  void requestSuperhero() {
    requestSubscription?.cancel();
    requestSubscription = request().asStream().listen(
      (superhero) {
        superheroSubject.add(superhero);
      },
      onError: (error, stackTrace) {
        print("Error happened requestSuperhero:$error,$stackTrace");
      },
    );
  }

  Future<Superhero> request() async {
    final token = dotenv.env["SUPERHERO_TOKEN"]; // access to our token
    final response = await (client ??= http.Client()).get(Uri.parse(
        "https://www.superheroapi.com/api/$token/search/$id")); //Link to our API
    if (response.statusCode >= 500 && response.statusCode <= 599) {
      throw ApiException("Server error happened");
    }
    if (response.statusCode >= 400 && response.statusCode <= 499) {
      throw ApiException("Client error happened");
    }
    final decoded = json.decode(response.body); //Json

    if (decoded['response'] == 'success') {
      return Superhero.fromJson(decoded);
    } else if (decoded['response'] == 'error') {
      throw ApiException("Client error happened");
    }
    throw Exception("Unknown error happened");
  }

  Stream<Superhero> observeSuperhero() => superheroSubject;

  void dispose() {
    client?.close();
    requestSubscription?.cancel();
    superheroSubject.close();
  }
}
