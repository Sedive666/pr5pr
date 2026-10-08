enum Role {
  client('Покупатель'),
  manager('Менеджер'),
  admin('Администратор');

  const Role(this.title);

  final String title;

  static Role? parse(Object? value) =>
      Role.values.where((r) => r.name == value).firstOrNull;
}

class AppUser {
  const AppUser({
    required this.id,
    required this.login,
    required this.name,
    required this.role,
    this.customerId,
    this.blocked = false,
  });

  final int id;
  final String login;
  final String name;
  final Role role;
  final int? customerId;
  final bool blocked;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as int,
    login: '${json['login']}',
    name: '${json['name']}',
    role: Role.parse(json['role']) ?? Role.client,
    customerId: json['customerId'] as int?,
    blocked: json['blocked'] == true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'login': login,
    'name': name,
    'role': role.name,
    'customerId': customerId,
    'blocked': blocked,
  };
}
