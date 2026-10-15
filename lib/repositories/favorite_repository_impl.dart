import 'package:waylo/models/destination.dart';
import 'package:waylo/repositories/favorite_repository.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final List<Destination> _favorites = []; //menyimpan daftar destinasi yang disukai 

  @override
  List<Destination> getFavorites() {
    return List.unmodifiable(_favorites);
  }

  @override
  //mengecek status favorit berdasarkan ID.
  bool isFavorite(int destinationId) {
    return _favorites.any( 
      (destination) => destination.id == destinationId,
    );
  }

  @override
  void toggleFavorite(Destination destination) {
    final index = _favorites.indexWhere(
      (item) => item.id == destination.id,
    );

    //kalau index yang membawa data destinasi gak ada di array _favorite bakal di tambahin
    //tapi kalau ada di favorite dan user ngirim indexnya lagi maka, bakal dihapus. 

    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(destination);
    }
  }
}
