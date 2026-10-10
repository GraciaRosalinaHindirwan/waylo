class User{
  final int id; 
  final String fullname; 
  final String username;
  final String password; 
  final List<String> destinations; 
  final List<String> categories;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.fullname,
    required this.username,
    required this.password,
    this.destinations = const [],
    this.categories = const [],
    required this.createdAt,
    required this.updatedAt
  }); 
}