import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:rxdart/rxdart.dart';
import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/main.dart';
import 'package:superheroes/pages/main_page.dart';
import 'package:superheroes/widgets/superhero_card.dart';

import 'lesson_2/task_1.dart';
import 'shared/internal/image_checks.dart';
import 'shared/internal/text_field_checks.dart';
// import 'shared/internal/image_checks.dart';
// import 'lesson_2/task_2.dart';
// import 'lesson_2/task_3.dart';
// import 'lesson_2/task_4.dart';

void main() {
  // group("l06h01", () => runTestLesson2Task1());
  // group("l06h02", () => runTestLesson2Task2());
  // group("l06h03", () => runTestLesson2Task3());
  group("l06h04", () => runTestLesson2Task4());
}
void runTestLesson2Task1() {
  testWidgets('module1', (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.runAsync(() async {
        final subject = BehaviorSubject<List<SuperheroInfo>>.seeded(SuperheroInfo.mocked);
        await tester.pumpWidget(
            MaterialApp(home: SuperheroesList(title: "Your favorites", stream: subject)));

        await tester.pump(Duration(milliseconds: 1));

        final listViewFinder = find.byType(ListView);
        expect(
          listViewFinder,
          findsOneWidget,
          reason: "There should be a ListView on the main screen",
        );

        final ListView listView = tester.widget(listViewFinder);
        expect(
          listView.keyboardDismissBehavior,
          ScrollViewKeyboardDismissBehavior.onDrag,
          reason:
          "There are no appropriate parameters added in ListView to hide keyboard on scroll",
        );

        await subject.close();
      });
    });
  });
}
void runTestLesson2Task2() {
  testWidgets('module2', (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final batmanSuperheroInfo = SuperheroInfo(
        name: "Batman",
        realName: "Bruce Wayne",
        imageUrl: "https://www.superherodb.com/pictures2/portraits/10/100/639.jpg",
      );
      await testOneSuperhero(tester, batmanSuperheroInfo);

      final ironmanSuperheroInfo = SuperheroInfo(
        name: "Ironman",
        realName: "Tony Stark",
        imageUrl: "https://www.superherodb.com/pictures2/portraits/10/100/85.jpg",
      );
      await testOneSuperhero(tester, ironmanSuperheroInfo);
    });
  });
}

Future<void> testOneSuperhero(final WidgetTester tester, final SuperheroInfo superheroInfo ) async {
  await tester.pumpWidget(MaterialApp(
    home: SuperheroCard(
      superheroInfo: superheroInfo,
      onTap: () {},
    ),
  ));
  expect(
    find.text(superheroInfo.name.toUpperCase()),
    findsOneWidget,
    reason: """
Cannot find Text widget with text '${superheroInfo.name.toUpperCase()}' in SuperheroCard.
Tested on superheroInfo: $superheroInfo
        """,
  );
  expect(
    find.text(superheroInfo.realName),
    findsOneWidget,
    reason: """
Cannot find Text widget with text '${superheroInfo.realName}' in SuperheroCard.
Tested on superheroInfo: $superheroInfo
        """,
  );

  final imageFinder = find.byType(Image);
  expect(
    imageFinder,
    findsOneWidget,
    reason: "Cannot find Image in SuperheroCard",
  );
  final Image image = tester.widget(imageFinder);
  checkImageProperties(
    image: image,
    imageProvider: NetworkImage(superheroInfo.imageUrl),
  );
}
void runTestLesson2Task3() {
  testWidgets('module3', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    final textFieldFinder = find.byType(TextField);

    expect(
      textFieldFinder,
      findsOneWidget,
      reason: "There should be a TextField widget on the main screen",
    );

    final TextField textField = tester.widget(textFieldFinder);

    checkTextFieldBorders(
      textField: textField,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.white, width: 2),
      ),
    );

    checkTextFieldCursorColor(
      textField: textField,
      cursorColor: Colors.white,
    );

    checkTextFieldTextInputAction(
      textField: textField,
      textInputAction: TextInputAction.search,
    );

    checkTextFieldTextCapitalization(
      textField: textField,
      textCapitalization: TextCapitalization.words,
    );
  });
}
void runTestLesson2Task4() {
  testWidgets('module4', (WidgetTester tester) async {
    await tester.runAsync(() async {
      final batman = SuperheroInfo(
        name: "Batman",
        realName: "Bruce Wayne",
        imageUrl: "https://www.superherodb.com/pictures2/portraits/10/100/639.jpg",
      );
      final ironman = SuperheroInfo(
        name: "Ironman",
        realName: "Tony Stark",
        imageUrl: "https://www.superherodb.com/pictures2/portraits/10/100/85.jpg",
      );
      final venom = SuperheroInfo(
        name: "Venom",
        realName: "Eddie Brock",
        imageUrl: 'https://www.superherodb.com/pictures2/portraits/10/100/22.jpg',
      );
      final MainBloc bloc = MainBloc();
      expect(
        await bloc.search("batm"),
        [batman],
        reason: "Searching 'batm' should return info about Batman",
      );
      expect(
        await bloc.search("BATM"),
        [batman],
        reason: "Searching 'BATM' should return info about Batman",
      );
      expect(
        await bloc.search("Batm"),
        [batman],
        reason: "Searching 'Batm' should return info about Batman",
      );
      expect(
        await bloc.search("man"),
        [batman, ironman],
        reason: "Searching 'man' should return info about Batman and Ironman",
      );
      expect(
        await bloc.search("MAN"),
        [batman, ironman],
        reason: "Searching 'MAN' should return info about Batman and Ironman",
      );
      expect(
        await bloc.search("maN"),
        [batman, ironman],
        reason: "Searching 'maN' should return info about Batman and Ironman",
      );
      expect(
        await bloc.search("veNOm"),
        [venom],
        reason: "Searching 'veNOm' should return info about Venom",
      );
      expect(
        await bloc.search("Tony"),
        [],
        reason: "Searching 'Tony' should return nothing",
      );
      expect(
        await bloc.search("Eddie"),
        [],
        reason: "Searching 'Eddie' should return nothing",
      );
    });
  });
}
