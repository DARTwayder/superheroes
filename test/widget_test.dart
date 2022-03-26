import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/main.dart';
import 'package:superheroes/pages/main_page.dart';
import 'package:superheroes/widgets/action_button.dart';
import 'package:superheroes/widgets/superhero_card.dart';
import 'lesson_1/shared.dart';
import 'shared/internal/container_checks.dart';
import 'shared/internal/finders.dart';
import 'shared/internal/image_checks.dart';
import 'shared/internal/text_checks.dart';


// import 'lesson_1/test_lesson_1_task_1.dart';
//  import 'lesson_1/test_lesson_1_task_2.dart';
// import 'lesson_1/test_lesson_1_task_3.dart';
// import 'lesson_1/test_lesson_1_task_4.dart';
import 'lesson_1/test_lesson_1_task_5.dart';

void main() {
  // group("l05h01", () => runTestLesson1Task1());
  // group("l05h02", () => runTestLesson1Task2());
  // group("l05h03", () => runTestLesson1Task3());
  // group("l05h04", () => runTestLesson1Task4());
  group("l05h05", () => runTestLesson1Task5());
}
void runTestLesson1Task1() {
  testWidgets('module1', (WidgetTester tester) async {

    await tester.pumpWidget(MyApp());

    final materialAppFinder = find.byType(MaterialApp);
    expect(
      materialAppFinder,
      findsOneWidget,
      reason: "There should be a MaterialApp widget in MyApp",
    );

    final MaterialApp materialApp = tester.widget<MaterialApp>(materialAppFinder);

    expect(
      materialApp.theme,
      isNotNull,
      reason: "You need to provide ThemeData in MaterialApp",
    );

    expect(
      materialApp.theme!.textTheme.bodyText1!.fontFamily,
      equals("OpenSans_regular"),
      reason: "Text theme should be equals to GoogleFonts.openSansTextTheme()",
    );

  });
}
void runTestLesson1Task2() {
  testWidgets('module2', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    final actionButtonFinder =
    findTypeByTextOnlyInParentType(ActionButton, "Next State".toUpperCase(), Stack);
    expect(
      actionButtonFinder,
      findsOneWidget,
      reason: "There should be an ActionButton with text 'NEXT STATE' in Stack",
    );

    final containerFinder =
    findTypeByTextOnlyInParentType(Container, "Next State".toUpperCase(), ActionButton);

    expect(
      containerFinder,
      findsOneWidget,
      reason: "There are should be a Container inside ActionButton",
    );

    final Container container = tester.firstWidget(containerFinder);

    checkContainerEdgeInsetsProperties(
      container: container,
      padding: EdgeInsetsCheck(left: 20, right: 20, top: 8, bottom: 8),
    );

    checkContainerDecorationBorderRadius(
      container: container,
      borderRadius: BorderRadius.circular(8),
    );

    checkContainerDecorationColor(
      container: container,
      color: const Color(0xFF00BCD4),
    );

    final gestureDetectorFinder =
    findTypeByTextOnlyInParentType(GestureDetector, "Next State".toUpperCase(), ActionButton);

    expect(
      gestureDetectorFinder,
      findsOneWidget,
      reason: "There are should be a GestureDetector inside ActionButton",
    );

    final GestureDetector gestureDetector = tester.firstWidget(gestureDetectorFinder);

    expect(
      gestureDetector.onTap,
      isNotNull,
      reason: "onTap parameter should be not null in GestureDetector",
    );

    expect(
      container.child,
      isInstanceOf<Text>(),
      reason: "Container should have child of Text type",
    );

    final Text text = container.child as Text;

    checkTextProperties(
      textWidget: text,
      textColor: const Color(0xFFFFFFFF),
      fontSize: 14,
      fontWeight: FontWeight.w700,
    );
  });
}

void runTestLesson1Task3() {
  testWidgets('module3', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    await reachNeededState(tester, MainPageState.minSymbols);

    final alignFinder = findTypeByTextOnlyInParentType(Align, "Enter at least 3 symbols", Stack);
    expect(
      alignFinder,
      findsOneWidget,
      reason: "There should be an Align inside Stack with text inside 'Enter at least 3 symbols'",
    );

    final Align align = tester.firstWidget(alignFinder);
    expect(
      align.alignment,
      Alignment.topCenter,
      reason: "Align should have Alignment.topCenter alignment property",
    );

    final paddingFinder =
    findTypeByTextOnlyInParentType(Padding, "Enter at least 3 symbols", Align);
    expect(
      paddingFinder,
      findsOneWidget,
      reason: "There should be a Padding inside Align",
    );

    final Padding padding = tester.firstWidget(paddingFinder);
    checkEdgeInsetParam(
      widgetName: "Padding",
      param: padding.padding,
      paramName: "",
      edgeInsetsCheck: EdgeInsetsCheck(top: 110),
    );

    final textFinder = find.text("Enter at least 3 symbols");
    expect(
      textFinder,
      findsOneWidget,
      reason: "There should be a Text with text 'Enter at least 3 symbols'",
    );

    final Text text = tester.firstWidget(textFinder);
    checkTextProperties(
      textWidget: text,
      textColor: const Color(0xFFFFFFFF),
      fontSize: 20,
      fontWeight: FontWeight.w600,
    );
  });
}
void runTestLesson1Task4() {
  testWidgets('module4', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    await reachNeededState(tester, MainPageState.noFavorites);

    final columnFinder = find.descendant(
      of: find.byType(MainPageStateWidget),
      matching: find.descendant(of: find.byType(Stack), matching: find.byType(Column)),
    );

    expect(
      columnFinder,
      findsOneWidget,
      reason: "There should be a Column inside Stack in MainPageContent",
    );

    final Column column = tester.widget(columnFinder);

    final centerFinder = findTypeByChildTypeOnlyInParentType(Center, Column, Stack);
    final Iterable<Center> centerWidgets = tester.widgetList(centerFinder);
    if (centerWidgets.length == 0) {
      final alignFinder = findTypeByChildTypeOnlyInParentType(Align, Column, Stack);
      expect(
        alignFinder,
        findsOneWidget,
        reason: "\nColumn either should have mainAxisAlignment = MainAxisAlignment.center \n"
            "or need to have mainAxisSize = MainAxisSize.min and be wrapped with Center or \n"
            "Align(alignment: Alignment.center) widgets",
      );
      final Align align = tester.widget(alignFinder);
      expect(
        align.alignment,
        Alignment.center,
        reason: "\nColumn either should have mainAxisAlignment = MainAxisAlignment.center \n"
            "or need to have mainAxisSize = MainAxisSize.min and be wrapped with Center or \n"
            "Align(alignment: Alignment.center) widgets",
      );
    }

    final stackInColumnFinder = find.descendant(of: columnFinder, matching: find.byType(Stack));

    expect(
      stackInColumnFinder,
      findsOneWidget,
      reason: "There should be a Stack inside Column",
    );

    final Stack stackInColumn = tester.firstWidget(stackInColumnFinder);

    expect(
      stackInColumn.children.length,
      2,
      reason: "There should be 2 widgets inside Stack: one with circle and other with image",
    );

    final Widget firstWidgetInStack = stackInColumn.children[0];

    expect(
      firstWidgetInStack,
      isInstanceOf<Container>(),
      reason: "First widget inside Stack should be a Container",
    );

    final Container container = firstWidgetInStack as Container;

    checkContainerDecorationShape(container: container, shape: BoxShape.circle);
    checkContainerDecorationColor(container: container, color: const Color(0xFF00BCD4));
    checkContainerWidthOrHeightProperties(
      container: container,
      widthAndHeight: WidthAndHeight(width: 108, height: 108),
    );

    final Widget secondWidgetInStack = stackInColumn.children[1];

    expect(
      secondWidgetInStack,
      isInstanceOf<Padding>(),
      reason: "Second widget inside Stack should be a Padding",
    );

    final Padding padding = secondWidgetInStack as Padding;

    checkEdgeInsetParam(
      widgetName: "Padding",
      param: padding.padding,
      paramName: "",
      edgeInsetsCheck: EdgeInsetsCheck(top: 9),
    );

    expect(
      padding.child,
      isInstanceOf<Image>(),
      reason: "Child of Padding should be an Image",
    );

    final Image image = padding.child as Image;
    checkImageProperties(
      image: image,
      width: 108,
      height: 119,
      imageProvider: AssetImage("assets/images/ironman.png"),
    );

    final noFavoritesYetTextFinder = find.text("No favorites yet");

    expect(
      noFavoritesYetTextFinder,
      findsOneWidget,
      reason: "There should be a Text with text 'No favorites yet'",
    );

    final Text noFavoritesYetText = tester.firstWidget(noFavoritesYetTextFinder);

    checkTextProperties(
      textWidget: noFavoritesYetText,
      textColor: const Color(0xFFFFFFFF),
      fontSize: 32,
      fontWeight: FontWeight.w800,
    );

    final searchAndAddTextFinder = find.text("Search and add".toUpperCase());

    expect(
      searchAndAddTextFinder,
      findsOneWidget,
      reason: "There should be a Text with text 'SEARCH AND ADD'",
    );

    final Text searchAndAddText = tester.firstWidget(searchAndAddTextFinder);

    checkTextProperties(
      textWidget: searchAndAddText,
      textColor: const Color(0xFFFFFFFF),
      fontSize: 16,
      fontWeight: FontWeight.w700,
    );

    final actionButtonWithSearchFinder =
    findTypeByTextOnlyInParentType(ActionButton, "SEARCH", Column);

    expect(
      actionButtonWithSearchFinder,
      findsOneWidget,
      reason: "There should be an ActionButton with text 'SEARCH'",
    );

    expect(
      column.children.length,
      7,
      reason:
      "There should be 7 widgets inside Column. 1 widget with circle and image, 2 widget with texts, 1 ActionButton and 3 empty SizedBoxes as paddings",
    );

    expect(
      column.children[1],
      isInstanceOf<SizedBox>(),
      reason: "Second widget in Column should be a SizedBox",
    );

    expect(
      (column.children[1] as SizedBox).height,
      20,
      reason: "SizedBox between widget with blue circle with iron man and title should be 20",
    );

    expect(
      column.children[3],
      isInstanceOf<SizedBox>(),
      reason: "Fourth widget in Column should be a SizedBox",
    );

    expect(
      (column.children[3] as SizedBox).height,
      20,
      reason: "SizedBox between title widget and subtitle should be 20",
    );

    expect(
      column.children[5],
      isInstanceOf<SizedBox>(),
      reason: "Sixth widget in Column should be a SizedBox",
    );

    expect(
      (column.children[5] as SizedBox).height,
      30,
      reason: "SizedBox between subtitle widget and ActionButton should be 30",
    );
  });
}
void runTestLesson1Task5() {
  testWidgets('module5', (WidgetTester tester) async {
    mockNetworkImagesFor(() async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      await reachNeededState(tester, MainPageState.favorites);

      final yourFavoritesTextFinder = find.text("Your favorites");

      expect(
        yourFavoritesTextFinder,
        findsOneWidget,
        reason: "There should be a Text with text 'Your favorites'",
      );

      final Text yourFavoritesText = tester.firstWidget(yourFavoritesTextFinder);

      checkTextProperties(
        textWidget: yourFavoritesText,
        textColor: const Color(0xFFFFFFFF),
        fontSize: 24,
        fontWeight: FontWeight.w800,
      );

      final columnFinder =
      findTypeByTextOnlyInParentType(Column, "Your favorites", MainPageStateWidget);

      expect(
        columnFinder,
        findsOneWidget,
        reason: "There should be a Column inside MainPageStateWidget ",
      );

      final Column column = tester.widget(columnFinder);

      final paddingOfText = find.descendant(
        of: columnFinder,
        matching: find.ancestor(
          of: yourFavoritesTextFinder,
          matching: find.byType(Padding),
        ),
      );

      expect(
        paddingOfText,
        findsOneWidget,
        reason: "Text with text 'Your favorites' should be wrapped with Padding",
      );

      final Padding yourFavoritesPadding = tester.widget(paddingOfText);

      checkEdgeInsetParam(
        widgetName: "Padding",
        param: yourFavoritesPadding.padding,
        paramName: "",
        edgeInsetsCheck: EdgeInsetsCheck(left: 16, right: 16),
      );

      final batmanCardFinder =
      findTypeByTextOnlyInParentType(SuperheroCard, "BATMAN", MainPageStateWidget);

      expect(
        batmanCardFinder,
        findsOneWidget,
        reason: "There should be a SuperheroCard with Batman",
      );

      final SuperheroCard batmanCard = tester.widget(batmanCardFinder);
      expect(
        batmanCard.name,
        "Batman",
        reason: "SuperheroCard with Batman should have 'Batman' as a name parameter",
      );
      expect(
        batmanCard.realName,
        "Bruce Wayne",
        reason: "SuperheroCard with Batman should have 'Bruce Wayne' as a realName parameter",
      );
      final batmanUrl = "https://www.superherodb.com/pictures2/portraits/10/100/639.jpg";
      expect(
        batmanCard.imageUrl,
        batmanUrl,
        reason: "SuperheroCard with Batman should have '$batmanUrl' as an imageUrl parameter",
      );

      final paddingOfBatmanCardTextFinder = find.descendant(
        of: columnFinder,
        matching: find.ancestor(
          of: batmanCardFinder,
          matching: find.byType(Padding),
        ),
      );

      expect(
        paddingOfBatmanCardTextFinder,
        findsOneWidget,
        reason: "SuperheroCard with Batman should be wrapped with Padding",
      );

      final Padding paddingOfBatmanCardText = tester.widget(paddingOfBatmanCardTextFinder);
      checkEdgeInsetParam(
        widgetName: "Padding",
        param: paddingOfBatmanCardText.padding,
        paramName: "",
        edgeInsetsCheck: EdgeInsetsCheck(left: 16, right: 16),
      );
      // --------------?

      final ironmanCardFinder =
      findTypeByTextOnlyInParentType(SuperheroCard, "IRONMAN", MainPageStateWidget);

      expect(
        ironmanCardFinder,
        findsOneWidget,
        reason: "There should be a SuperheroCard with Ironman",
      );

      final SuperheroCard ironmanCard = tester.widget(ironmanCardFinder);
      expect(
        ironmanCard.name,
        "Ironman",
        reason: "SuperheroCard with Batman should have 'Ironman' as a name parameter",
      );
      expect(
        ironmanCard.realName,
        "Tony Stark",
        reason: "SuperheroCard with Batman should have 'Tony Stark' as a realName parameter",
      );
      final ironmanUrl = "https://www.superherodb.com/pictures2/portraits/10/100/85.jpg";
      expect(
        ironmanCard.imageUrl,
        ironmanUrl,
        reason: "SuperheroCard with Batman should have '$ironmanUrl' as an imageUrl parameter",
      );

      final paddingOfIronmanCardTextFinder = find.descendant(
        of: columnFinder,
        matching: find.ancestor(
          of: ironmanCardFinder,
          matching: find.byType(Padding),
        ),
      );

      expect(
        paddingOfIronmanCardTextFinder,
        findsOneWidget,
        reason: "SuperheroCard with Ironman should be wrapped with Padding",
      );

      final Padding paddingOfIronmanCardText = tester.widget(paddingOfIronmanCardTextFinder);
      checkEdgeInsetParam(
        widgetName: "Padding",
        param: paddingOfIronmanCardText.padding,
        paramName: "",
        edgeInsetsCheck: EdgeInsetsCheck(left: 16, right: 16),
      );

      final containerInsideSuperheroCard = find.descendant(
        of: batmanCardFinder,
        matching: find.ancestor(
          of: find.byType(Row),
          matching: find.byType(Container),
        ),
      );

      expect(
        containerInsideSuperheroCard,
        findsOneWidget,
        reason: "SuperheroCard should have a Container above the Row",
      );

      final Container topLevelSuperheroCardContainer = tester.widget(containerInsideSuperheroCard);
      checkContainerColor(
        container: topLevelSuperheroCardContainer,
        color: const Color(0xFF2C3243),
      );
      checkContainerWidthOrHeightProperties(
        container: topLevelSuperheroCardContainer,
        widthAndHeight: WidthAndHeight(height: 70),
      );

      final superheroCardRowFinder = find.descendant(
        of: batmanCardFinder,
        matching: find.byType(Row),
      );

      expect(
        superheroCardRowFinder,
        findsOneWidget,
        reason: "SuperheroCard should have a Row inside Container",
      );

      final Row superheroCardRow = tester.widget(superheroCardRowFinder);
      expect(
        superheroCardRow.children.length,
        3,
        reason: "Row inside SuperheroCard should have 3 children widgets",
      );

      expect(
        superheroCardRow.children[0],
        isInstanceOf<Image>(),
        reason: "First child in Row inside SuperheroCard should be an Image",
      );

      final Image imageInSuperHeroCard = superheroCardRow.children[0] as Image;
      checkImageProperties(
        image: imageInSuperHeroCard,
        height: 70,
        width: 70,
        boxFit: BoxFit.cover,
      );

      expect(
        superheroCardRow.children[1],
        isInstanceOf<SizedBox>(),
        reason: "Second child in Row inside SuperheroCard should be a SizedBox",
      );
      final SizedBox sizedBoxInsideSuperheroCard = superheroCardRow.children[1] as SizedBox;
      expect(
        sizedBoxInsideSuperheroCard.width,
        12,
        reason: "SizedBox inside Row in SuperheroCard should have 12 width",
      );

      expect(
        superheroCardRow.children[2],
        isInstanceOf<Expanded>(),
        reason: "Third child in Row inside SuperheroCard should be a Expanded",
      );

      expect(
        (superheroCardRow.children[2] as Expanded).child,
        isInstanceOf<Column>(),
        reason: "Third child in Row inside SuperheroCard should be a Expanded with Column as a child",
      );

      final Column columnInsideSuperheroCard = (superheroCardRow.children[2] as Expanded).child as Column;
      expect(
        columnInsideSuperheroCard.children.length,
        2,
        reason: "Column inside SuperheroCard should have 2 children widgets",
      );

      expect(
        columnInsideSuperheroCard.crossAxisAlignment,
        CrossAxisAlignment.start,
        reason:
        "Column inside SuperheroCard should have crossAxisAlignment = CrossAxisAlignment.start",
      );
      expect(
        columnInsideSuperheroCard.mainAxisAlignment,
        MainAxisAlignment.center,
        reason:
        "Column inside SuperheroCard should have mainAxisAlignment = MainAxisAlignment.center",
      );

      expect(
        columnInsideSuperheroCard.children[0],
        isInstanceOf<Text>(),
        reason: "Column inside SuperheroCard should have two Text widgets",
      );

      expect(
        columnInsideSuperheroCard.children[1],
        isInstanceOf<Text>(),
        reason: "Column inside SuperheroCard should have two Text widgets",
      );

      expect(
        column.children.length,
        6,
        reason: "There should be 6 widgets inside Column. Widget with text 'Your favorites',"
            " SuperheroCard with Batman, SuperheroCard with Ironman and 3 SizedBoxes",
      );

      expect(
        column.children[0],
        isInstanceOf<SizedBox>(),
        reason: "First widget in Column should be a SizedBox",
      );

      expect(
        (column.children[0] as SizedBox).height,
        90,
        reason: "Top SizedBox should have 90 height",
      );

      expect(
        column.children[2],
        isInstanceOf<SizedBox>(),
        reason: "Third widget in Column should be a SizedBox",
      );

      expect(
        (column.children[2] as SizedBox).height,
        20,
        reason: "Top SizedBox between title and first SuperheroCard should have 20 height",
      );

      expect(
        column.children[4],
        isInstanceOf<SizedBox>(),
        reason: "Fifth widget in Column should be a SizedBox",
      );

      expect(
        (column.children[4] as SizedBox).height,
        8,
        reason: "SizedBox between two SuperheroCards should have 8 height",
      );
    });
  });
}
