import '../../modules/student/widegts/hostel_listing.dart';
import 'hostel_model.dart';

class HostelFilter {
  final String? city;
  final double? minPrice;
  final double? maxPrice;

  final Set<int> roomTypes;
  final Set<HostelGender> genders;
  final Set<String> amenities;

  const HostelFilter({
    this.city,
    this.minPrice,
    this.maxPrice,
    this.roomTypes = const {},
    this.genders = const {},
    this.amenities = const {},
  });

  bool get isActive =>
      city != null ||
          minPrice != null ||
          maxPrice != null ||
          roomTypes.isNotEmpty ||
          genders.isNotEmpty ||
          amenities.isNotEmpty;

  bool matches(HostelListing l) {
    final h = l.hostel;

    if (city != null && h.city.trim().toLowerCase() != city!.toLowerCase()) {
      return false;
    }

    if (minPrice != null || maxPrice != null) {
      final price = l.displayPrice;
      if (price == null || price <= 0) return false;
      if (minPrice != null && price < minPrice!) return false;
      if (maxPrice != null && price > maxPrice!) return false;
    }

    if (roomTypes.isNotEmpty && !roomTypes.any(l.seaters.contains)) {
      return false;
    }

    if (genders.isNotEmpty) {
      final wantsSingleGender =
          genders.contains(HostelGender.male) || genders.contains(HostelGender.female);
      final ok = genders.contains(h.gender) ||
          (h.gender == HostelGender.coLiving && wantsSingleGender);
      if (!ok) return false;
    }

    if (amenities.isNotEmpty) {
      final have = h.amenities.map((e) => e.trim().toLowerCase()).toSet();
      if (!amenities.every((a) => have.contains(a.toLowerCase()))) return false;
    }
    return true;
  }
}