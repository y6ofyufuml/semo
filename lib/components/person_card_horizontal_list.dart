import "package:flutter/material.dart";
import "package:build_x/components/horizontal_media_list.dart";
import "package:build_x/components/person_card.dart";
import "package:build_x/models/person.dart";
import "package:build_x/screens/person_media_screen.dart";
import "package:build_x/utils/navigation_helper.dart";

class PersonCardHorizontalList extends StatelessWidget {
  const PersonCardHorizontalList({
    super.key,
    required this.title,
    required this.people,
  });

  final String title;
  final List<Person> people;

  @override
  Widget build(BuildContext context) => HorizontalMediaList<Person>(
    title: title,
    items: people,
    itemBuilder: (BuildContext context, Person person, int index) => Padding(
      padding: EdgeInsets.only(
        right: index < people.length - 1 ? 18 : 0,
      ),
      child: PersonCard(
        person: person,
        onTap: () => NavigationHelper.navigate(
          context,
          PersonMediaScreen(person),
        ),
      ),
    ),
  );
}