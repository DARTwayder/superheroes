import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superheroes/model/superhero.dart';

class FavoriteSuperheroesStorage {
  static const _key = "favorite_superheroes";

  final updater = PublishSubject<Null>();

  //статический конструктор,возвращает инстанс
  static FavoriteSuperheroesStorage? _instance;

  factory FavoriteSuperheroesStorage.getInstance() =>
      _instance ??= FavoriteSuperheroesStorage._internal();

  FavoriteSuperheroesStorage._internal();

  //Метод добавления в избраное
  Future<bool> addToFavorites(final Superhero superhero) async {
    // Если лист пустой
    final rawSuperheroes = await _getRawSuperheroes();
    rawSuperheroes.add(json.encode(superhero.toJson()));
    return _setRawSuperheroes(rawSuperheroes);
  }

  //Метод удаления из избранного
  Future<bool> removeFromFavorites(final String id) async {
    // Если лист пустой
    final superheroes = await _getSuperheroes();
    superheroes.removeWhere((superhero) => superhero.id == id);
    return _setSuperheroes(superheroes);
  }

  // 2 Метода вспомогательных для добавления и удаления из избранного
  Future<List<String>> _getRawSuperheroes() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getStringList(_key) ?? [];
  }

  Future<bool> _setRawSuperheroes(final List<String> rawSuperheroes) async {
    final sp = await SharedPreferences.getInstance();
    final result = sp.setStringList(_key, rawSuperheroes);
    updater.add(null);
    return result;
  }

  // еще 2 доп Метода
  Future<List<Superhero>> _getSuperheroes() async {
    final rawSuperheroes = await _getRawSuperheroes();
    return rawSuperheroes
        .map((rawSuperhero) => Superhero.fromJson(json.decode(rawSuperhero)))
        .toList();
  }

  Future<bool> _setSuperheroes(final List<Superhero> superheroes) async {
    final rawSuperheroes = superheroes
        .map((superhero) => json.encode(superhero.toJson()))
        .toList();
    return _setRawSuperheroes(rawSuperheroes);
  }

  //Метод оффлайн просмотра избранного
  Future<Superhero?> getSuperhero(final String id) async {
    final superheroes = await _getSuperheroes();
    for (final superhero in superheroes) {
      if (superhero.id == id) {
        return superhero;
      }
    }
    return null;
  }

  // Метод будет выдавать список со всем избранным,которые будут обображатся на мейн странице при входе на экран
  // Метод Observe
  Stream<List<Superhero>> observeFavoriteSuperheroes() async* {
    yield await _getSuperheroes();
    await for (final _ in updater) {
      yield await _getSuperheroes();
    }
  }

  // Метод хелпер для определения,есть ли у нас уже это в избранном
  Stream<bool> observeIsFavorite(final String id) {
    return observeFavoriteSuperheroes().map(
        (superheroes) => superheroes.any((superhero) => superhero.id == id));
  }
}