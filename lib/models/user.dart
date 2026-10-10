class User{
  final int id; 
  final String fullname; 
  final String username;
  final String password; 
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.fullname,
    required this.username,
    required this.password,
    required this.createdAt,
    required this.updatedAt
  }); 
}