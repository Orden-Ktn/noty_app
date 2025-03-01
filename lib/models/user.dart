import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String username;

  @Index(unique: true)
  late String email;

  late String passwordHash;
}