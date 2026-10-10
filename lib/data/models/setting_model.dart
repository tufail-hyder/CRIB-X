enum PaymentAccountType {
  bank,
  online;

  String get label => this == PaymentAccountType.bank ? 'Bank Transfer' : 'Online';

  static PaymentAccountType fromString(String? v) => PaymentAccountType.values
      .firstWhere((e) => e.name == v, orElse: () => PaymentAccountType.bank);
}

/// Hostel owner ka wo account jahan students fees bhej sakte hain.
class PaymentAccount {
  final PaymentAccountType type;
  final String title; // account holder ka naam
  final String number; // account / IBAN / mobile account number
  final String provider; // Bank ya wallet ka naam (optional)

  const PaymentAccount({
    required this.type,
    required this.title,
    required this.number,
    this.provider = '',
  });

  factory PaymentAccount.fromJson(Map<String, dynamic> j) => PaymentAccount(
    type: PaymentAccountType.fromString(j['type']),
    title: j['title'] ?? '',
    number: j['number'] ?? '',
    provider: j['provider'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'title': title,
    'number': number,
    'provider': provider,
  };
}

class NotificationPrefs {
  final bool newBooking;
  final bool rentDue;
  final bool complaint;
  final bool subscriptionExpiry;

  const NotificationPrefs({
    this.newBooking = true,
    this.rentDue = true,
    this.complaint = true,
    this.subscriptionExpiry = true,
  });

  factory NotificationPrefs.fromJson(Map<String, dynamic> j) =>
      NotificationPrefs(
        newBooking: j['newBooking'] ?? true,
        rentDue: j['rentDue'] ?? true,
        complaint: j['complaint'] ?? true,
        subscriptionExpiry: j['subscriptionExpiry'] ?? true,
      );

  Map<String, dynamic> toJson() => {
    'newBooking': newBooking,
    'rentDue': rentDue,
    'complaint': complaint,
    'subscriptionExpiry': subscriptionExpiry,
  };
}

/// Settings page ka poora data (3 jagah se aata hai: users, users/private/kyc, hostels)
class AdminSettings {
  final String? photoUrl;
  final String hostelName;
  final String city;
  final String cnic;
  final String phone;
  final NotificationPrefs notifications;
  final double defaultRoomPrice;
  final String currency;
  final String language;
  final List<PaymentAccount> paymentAccounts;

  const AdminSettings({
    this.photoUrl,
    required this.hostelName,
    required this.city,
    required this.cnic,
    required this.phone,
    required this.notifications,
    required this.defaultRoomPrice,
    required this.currency,
    required this.language,
    required this.paymentAccounts,
  });

  factory AdminSettings.fromDocs({
    required Map<String, dynamic> user,
    required Map<String, dynamic> kyc,
    required Map<String, dynamic> hostel,
  }) {
    final rawAccounts = hostel['paymentAccounts'];
    final accounts = <PaymentAccount>[];
    if (rawAccounts is List) {
      for (final a in rawAccounts) {
        if (a is Map) {
          accounts.add(PaymentAccount.fromJson(Map<String, dynamic>.from(a)));
        }
      }
    }

    final rawNotif = hostel['notifications'];

    return AdminSettings(
      photoUrl: user['photoUrl'],
      hostelName: hostel['name'] ?? '',
      city: hostel['city'] ?? '',
      cnic: kyc['cnic'] ?? '',
      phone: user['phone'] ?? '',
      notifications: rawNotif is Map
          ? NotificationPrefs.fromJson(Map<String, dynamic>.from(rawNotif))
          : const NotificationPrefs(),
      defaultRoomPrice: (hostel['defaultRoomPrice'] as num?)?.toDouble() ?? 0,
      currency: hostel['currency'] ?? 'PKR',
      language: hostel['language'] ?? 'English',
      paymentAccounts: accounts,
    );
  }
}