import '../../../data/models/hostel_model.dart';


class HostelListing {
  final HostelModel hostel;

  final int? availableBeds;
  final Set<int> seaters;
  final double? minRoomPrice;

  const HostelListing(
      this.hostel, {
        this.availableBeds,
        this.seaters = const {},
        this.minRoomPrice,
      });

  bool get isFull => availableBeds != null && availableBeds == 0;

  double? get displayPrice =>
      hostel.monthlyPrice > 0 ? hostel.monthlyPrice : minRoomPrice;
}

class HostelDetailsArgs {
  final HostelListing listing;
  final List<HostelListing> all;
  const HostelDetailsArgs(this.listing, this.all);
}