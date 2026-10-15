import 'package:waylo/models/destination.dart';

abstract class DestinationRepository {
  Future<Destination> createDestination(Destination destination);

  Future<Destination?> getDestinationById(int id);

  Future<List<Destination>> getAllDestinations();

  Future<List<Destination>> getDestinationsByCategory(
    int categoryId,
  );

  Future<Destination> updateDestination(Destination destination);

  Future<void> deleteDestination(int id);
}