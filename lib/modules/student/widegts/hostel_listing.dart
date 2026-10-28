import '../../../data/models/hostel_model.dart';

class HostelListing {
  final HostelModel hostel;

  final int? availableBeds;

  const HostelListing(this.hostel, this.availableBeds);

  bool get isFull => availableBeds != null && availableBeds == 0;
}