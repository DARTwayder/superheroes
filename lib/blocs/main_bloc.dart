import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:superheroes/exception/api_exception.dart';
import 'package:superheroes/favorite_superheroes_storage.dart';
import 'package:superheroes/model/alignment_info.dart';
import 'package:superheroes/model/superhero.dart';

class MainBloc {
  static const minSymbols = 3;

  final BehaviorSubject<MainPageState> stateSubject = BehaviorSubject();
  final searchedSuperheroesSubject = BehaviorSubject<List<SuperheroInfo>>();
  final currentTextSubject = BehaviorSubject<String>.seeded("");

  StreamSubscription? textSubscription;
  StreamSubscription? searchSubscription;
  StreamSubscription? removeFromFavoritesSubscription;

  http.Client? client;

  MainBloc({this.client}) {
        textSubscription =
        Rx.combineLatest2<String, List<Superhero>, MainPageStateInfo>(
            currentTextSubject
                .distinct()
                .debounceTime(const Duration(milliseconds: 500)),
            FavoriteSuperheroesStorage.getInstance()
                .observeFavoriteSuperheroes(),
            (searchedText, favorietes) =>
                MainPageStateInfo(searchedText, favorietes.isNotEmpty)).listen(
      (value) {
        print("CHANGED $value");
        searchSubscription?.cancel();
        if (value.searchedText.isEmpty) {
          if (value.haveFavorites) {
            stateSubject.add(MainPageState.favorites);
          } else {
            stateSubject.add(MainPageState.noFavorites);
          }
        } else if (value.searchedText.length < minSymbols) {
          stateSubject.add(MainPageState.minSymbols);
        } else {
          searchForSuperheroes(value.searchedText);
        }
      },
    );
  }

  void searchForSuperheroes(final String text) {
    stateSubject.add(MainPageState.loading);
    searchSubscription = search(text).asStream().listen(
      (searchResults) {
        if (searchResults.isEmpty) {
          stateSubject.add(MainPageState.nothingFound);
        } else {
          searchedSuperheroesSubject.add(searchResults);
          stateSubject.add(MainPageState.searchResults);
        }
      },
      onError: (error, stackTrace) {
        stateSubject.add(MainPageState.loadingError);
      },
    );
  }

  void removeFromFavorites(final String id) {
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

  void retry() {
    final currentText = currentTextSubject.value;
    searchForSuperheroes(currentText);
  }

  Stream<List<SuperheroInfo>> observeFavoriteSuperheroes() =>
      FavoriteSuperheroesStorage.getInstance().observeFavoriteSuperheroes().map(
          (superheroes) => superheroes
              .map((superhero) => SuperheroInfo.fromSuperhero(superhero))
              .toList());

  Stream<List<SuperheroInfo>> observeSearchedSuperheroes() =>
      searchedSuperheroesSubject;

  Future<List<SuperheroInfo>> search(final String text) async {
    //our BLoC
    final token = dotenv.env["SUPERHERO_TOKEN"]; // access to our token
    final response = await (client ??= http.Client()).get(Uri.parse(
        "https://www.superheroapi.com/api/$token/search/$text")); //Link to our API
    if (response.statusCode >= 500 && response.statusCode <= 599) {
      throw ApiException("Server error happened");
    }
    if (response.statusCode >= 400 && response.statusCode <= 499) {
      throw ApiException("Client error happened");
    }
    final decoded = json.decode(response.body); //Json

    if (decoded['response'] == 'success') {
      final List<dynamic> results = decoded['results'];
      final List<Superhero> superheroes = results
          .map((rawSuperhero) => Superhero.fromJson(rawSuperhero))
          .toList();
      final List<SuperheroInfo> found = superheroes.map((superhero) {
        return SuperheroInfo.fromSuperhero(superhero);
      }).toList();
      return found;
    } else if (decoded['response'] == 'error') {
      if (decoded['error'] == 'character with given name not found') {
        return [];
      }
      throw ApiException("Client error happened");
    }
    throw Exception("Unknown error happened");
  }

  Stream<MainPageState> observeMainPageState() => stateSubject;

  void nextState() {
    final currentState = stateSubject.value;
    final nextState = MainPageState.values[
        (MainPageState.values.indexOf(currentState) + 1) %
            MainPageState.values.length];
    stateSubject.add(nextState);
  }

  void updateText(final String? text) {
    currentTextSubject.add(text ?? "");
  }

  void dispose() {
    //dispose method
    stateSubject.close();
    searchedSuperheroesSubject.close();
    currentTextSubject.close();
    searchSubscription?.cancel();
    textSubscription?.cancel();
    client?.close();
    removeFromFavoritesSubscription?.cancel();
  }
}

enum MainPageState {
  noFavorites,
  minSymbols,
  loading,
  nothingFound,
  loadingError,
  searchResults,
  favorites,
}

class SuperheroInfo {
  final String id;
  final String name;
  final String realName;
  final String imageUrl;
  final AlignmentInfo? alignmentInfo;

  const SuperheroInfo({
    required this.id,
    required this.name,
    required this.realName,
    required this.imageUrl,
    this.alignmentInfo,
  });

  factory SuperheroInfo.fromSuperhero(final Superhero superhero) {
    return SuperheroInfo(
      id: superhero.id,
      name: superhero.name,
      realName: superhero.biography.fullName,
      imageUrl: superhero.image.url,
      alignmentInfo: superhero.biography.alignmentInfo,
    );
  }

  @override
  String toString() {
    return 'SuperheroInfo{id: $id, name: $name, realName: $realName, imageUrl: $imageUrl}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuperheroInfo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          realName == other.realName &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ realName.hashCode ^ imageUrl.hashCode;
  static const mocked = [
    SuperheroInfo(
      id: "70",
      name: "Batman",
      realName: "Bruce Wayne",
      imageUrl:
          "https://www.superherodb.com/pictures2/portraits/10/100/639.jpg",
    ),
    SuperheroInfo(
      id: "732",
      name: "Ironman",
      realName: "Tony Stark",
      imageUrl: "https://www.superherodb.com/pictures2/portraits/10/100/85.jpg",
    ),
    SuperheroInfo(
      id: "687",
      name: "Venom",
      realName: "Eddie Brock",
      imageUrl: "https://www.superherodb.com/pictures2/portraits/10/100/22.jpg",
    ),
  ];
}

class MainPageStateInfo {
  final String searchedText;
  final bool haveFavorites;

  const MainPageStateInfo(this.searchedText, this.haveFavorites);

  @override
  String toString() {
    return 'MainPageStateInfo{searchText: $searchedText, haveFavorites: $haveFavorites}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MainPageStateInfo &&
          runtimeType == other.runtimeType &&
          searchedText == other.searchedText;

  @override
  int get hashCode => searchedText.hashCode;
}
