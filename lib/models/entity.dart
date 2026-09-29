abstract class Entity {
  const Entity();

  int get id;
  DateTime? get deletedAt;
  bool get isDeleted => deletedAt != null;
}
