import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import '../exception/api_exception.dart';
import '../favorite_superheroes_storage.dart';
import '../model/superhero.dart';

class SuperheroBloc {
  http.Client? client;
  final String id;

  final superheroSubject = BehaviorSubject<Superhero>();

  StreamSubscription? getFromFavoritesSubscription;
  StreamSubscription? requestSubscription;
  StreamSubscription? addToFavoriteSubscription;
  StreamSubscription? removeFromFavoritesSubscription;

  SuperheroBloc({this.client, required this.id}) {
    getFromFavorites();
  }

  void getFromFavorites() {
    getFromFavoritesSubscription?.cancel();
    getFromFavoritesSubscription = FavoriteSuperheroesStorage.getInstance()
        .getSuperhero(id)
        .asStream()
        .listen(
      (superhero) {
        if (superhero != null) {
          superheroSubject.add(superhero);
        }
        requestSuperhero();
      },
      onError: (error, stackTrace) {
        print("Error happened addFavorite:$error,$stackTrace");
      },
    );
  }

  void addToFavorite() {
    final superhero = superheroSubject.valueOrNull;
    if (superhero == null) {
      print("ERROR: superhero is null while shouldn't be");
      return;
    }
    addToFavoriteSubscription?.cancel();
    addToFavoriteSubscription = FavoriteSuperheroesStorage.getInstance()
        .addToFavorites(superhero)
        .asStream()
        .listen(
      (event) {
        print("Added to favorites:$event");
      },
      onError: (error, stackTrace) {
        print("Error happened addFavorite:$error,$stackTrace");
      },
    );
  }

  void removeFromFavorites() {
    removeFromFavoritesSubscription?.cancel();
    removeFromFavoritesSubscription = FavoriteSuperheroesStorage.getInstance()
        .removeFromFavorites(id)
        .asStream()
        .listen(
      (event) {
        print("Removed from favorites:$event");
      },
      onError: (error, stackTrace) {
        print("Error happened removeFromFavorites:$error,$stackTrace");
      },
    );
  }

  Stream<bool> observeIsFavorite() =>
      FavoriteSuperheroesStorage.getInstance().observeIsFavorite(id);


  //Поиск на сервере
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
        "https://www.superheroapi.com/api/$token/$id")); //Link to our API
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
//Стрим с супергероем
  Stream<Superhero> observeSuperhero() => superheroSubject;

  void dispose() {
    client?.close();
    requestSubscription?.cancel();
    superheroSubject.close();
    addToFavoriteSubscription?.cancel();
    removeFromFavoritesSubscription?.cancel();
    getFromFavoritesSubscription?.cancel();
  }
}