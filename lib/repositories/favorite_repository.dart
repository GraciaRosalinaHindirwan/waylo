
import 'package:waylo/models/destination.dart';

abstract class FavoriteRepository {
  List<Destination> getFavorites();

  bool isFavorite(int destinationId);

  void toggleFavorite(Destination destination);
}
