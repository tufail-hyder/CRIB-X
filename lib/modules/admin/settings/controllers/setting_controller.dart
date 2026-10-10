import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/exceptions/exception_handler.dart';
import '../../../../core/network/network_manager.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/setting_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/setting_repository.dart';
import '../../../../shared/popups/app_dialogs.dart';
import '../../../../shared/popups/app_snackbar.dart';

class AccountDraft {
  final type = PaymentAccountType.bank.obs;
  final titleCtrl = TextEditingController();
  final numberCtrl = TextEditingController();
  final providerCtrl = TextEditingController();

  AccountDraft([PaymentAccount? a]) {
    if (a != null) {
      type.value = a.type;
      titleCtrl.text = a.title;
      numberCtrl.text = a.number;
      providerCtrl.text = a.provider;
    }
  }

  bool get isEmpty =>
      titleCtrl.text.trim().isEmpty &&
          numberCtrl.text.trim().isEmpty &&
          providerCtrl.text.trim().isEmpty;

  void dispose() {
    titleCtrl.dispose();
    numberCtrl.dispose();
    providerCtrl.dispose();
  }
}

class SettingsController extends GetxController {
  final SettingsRepository _repo;
  final AuthRepository _auth;
  SettingsController(this._repo, this._auth);

  final formKey = GlobalKey<FormState>();

  // Account
  final hostelNameCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final cnicCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final photoUrl = RxnString();

  // Notifications
  final newBooking = true.obs;
  final rentDue = true.obs;
  final complaint = true.obs;

  // Preferences
  final defaultPriceCtrl = TextEditingController();
  final currency = 'PKR'.obs;
  final language = 'English'.obs;

  // Security
  final currentPassCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  // Payment accounts
  final accounts = <AccountDraft>[].obs;

  final isLoading = true.obs;
  final isSaving = false.obs;
  final isUploadingPhoto = false.obs;
  final isDirty = false.obs;
  final errorMessage = RxnString();

  final _picker = ImagePicker();
  bool _filling = false;

  List<TextEditingController> get _watched => [
    hostelNameCtrl,
    cityCtrl,
    cnicCtrl,
    phoneCtrl,
    defaultPriceCtrl,
    currentPassCtrl,
    newPassCtrl,
    confirmPassCtrl,
  ];

  @override
  void onInit() {
    super.onInit();
    for (final c in _watched) {
      c.addListener(markDirty);
    }
  }

  @override
  void onReady() {
    super.onReady();
    load();
  }

  void markDirty() {
    if (!_filling) isDirty.value = true;
  }

  // ------------------------------------------------------------------
  Future<void> load() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      await NetworkManager.instance.ensureConnected();
      _fill(await _repo.load(_auth.currentUid ?? ''));
    } catch (e, s) {
      errorMessage.value = ExceptionHandler.message(e, s);
    } finally {
      isLoading.value = false;
    }
  }

  void _fill(AdminSettings s) {
    _filling = true;
    hostelNameCtrl.text = s.hostelName;
    cityCtrl.text = s.city;
    cnicCtrl.text = s.cnic;
    phoneCtrl.text = s.phone;
    photoUrl.value = s.photoUrl;

    newBooking.value = s.notifications.newBooking;
    rentDue.value = s.notifications.rentDue;
    complaint.value = s.notifications.complaint;

    defaultPriceCtrl.text =
    s.defaultRoomPrice > 0 ? s.defaultRoomPrice.toStringAsFixed(0) : '';
    currency.value = s.currency;
    language.value = s.language;

    for (final a in accounts) {
      a.dispose();
    }
    accounts.assignAll(s.paymentAccounts.map(AccountDraft.new));

    _filling = false;
    isDirty.value = false;
  }

  // ------------------------------------------------------------------
  Future<void> pickPhoto() async {
    try {
      final x = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 800,
      );
      if (x == null) return;

      isUploadingPhoto.value = true;
      await NetworkManager.instance.ensureConnected();
      photoUrl.value = await _repo.uploadPhoto(File(x.path));
      markDirty();
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  void setType(AccountDraft d, PaymentAccountType t) {
    d.type.value = t;
    markDirty();
  }

  void addAccount() {
    accounts.add(AccountDraft());
    markDirty();
  }

  void removeAccount(AccountDraft d) {
    accounts.remove(d);
    d.dispose();
    markDirty();
  }

  // ------------------------------------------------------------------
  // Validators
  String? validateCnic(String? v) {
    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
    return digits.length == 13 ? null : 'Enter a valid CNIC (13 digits)';
  }

  String? validateDefaultPrice(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return null; // optional
    final n = double.tryParse(t);
    return (n == null || n <= 0) ? 'Enter a valid amount' : null;
  }

  bool get _wantsPasswordChange =>
      currentPassCtrl.text.isNotEmpty ||
          newPassCtrl.text.isNotEmpty ||
          confirmPassCtrl.text.isNotEmpty;

  String? validateCurrentPass(String? v) =>
      _wantsPasswordChange && (v ?? '').isEmpty
          ? 'Enter your current password'
          : null;

  String? validateNewPass(String? v) {
    if (!_wantsPasswordChange) return null;
    if ((v ?? '').length < 6) return 'At least 6 characters';
    if (v == currentPassCtrl.text) return 'New password must be different';
    return null;
  }

  String? validateConfirmPass(String? v) =>
      _wantsPasswordChange && v != newPassCtrl.text
          ? 'Passwords do not match'
          : null;

  /// Account me kuch bhi bhara hai to title aur number dono zaroori
  String? validateAccountField(AccountDraft d, String? v, String label) {
    if (d.isEmpty) return null;
    return (v ?? '').trim().isEmpty ? '$label is required' : null;
  }

  String? validateAccountNumber(AccountDraft d, String? v) {
    final base = validateAccountField(d, v, 'Account number');
    if (base != null) return base;
    if (!d.isEmpty && (v ?? '').trim().length < 6) return 'Too short';
    return null;
  }

  String? validatePhone(String? v) => Validators.phone(v);

  // ------------------------------------------------------------------
  /// 13 digits ho to 12345-1234567-1 format
  String _formatCnic(String raw) {
    final d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.length != 13) return raw.trim();
    return '${d.substring(0, 5)}-${d.substring(5, 12)}-${d.substring(12)}';
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isSaving.value = true;
      await NetworkManager.instance.ensureConnected();

      // 1) Password pehle: galat current password par kuch save na ho
      final changingPassword = _wantsPasswordChange;
      if (changingPassword) {
        await _auth.changePassword(currentPassCtrl.text, newPassCtrl.text);
      }

      final settings = AdminSettings(
        photoUrl: photoUrl.value,
        hostelName: hostelNameCtrl.text.trim(),
        city: cityCtrl.text.trim(),
        cnic: _formatCnic(cnicCtrl.text),
        phone: phoneCtrl.text.trim(),
        notifications: NotificationPrefs(
          newBooking: newBooking.value,
          rentDue: rentDue.value,
          complaint: complaint.value,
        ),
        defaultRoomPrice: double.tryParse(defaultPriceCtrl.text.trim()) ?? 0,
        currency: currency.value,
        language: language.value,
        paymentAccounts: accounts
            .where((a) => !a.isEmpty)
            .map((a) => PaymentAccount(
          type: a.type.value,
          title: a.titleCtrl.text.trim(),
          number: a.numberCtrl.text.trim(),
          provider: a.providerCtrl.text.trim(),
        ))
            .toList(),
      );
      await _repo.save(_auth.currentUid ?? '', settings);

      _filling = true;
      currentPassCtrl.clear();
      newPassCtrl.clear();
      confirmPassCtrl.clear();
      cnicCtrl.text = settings.cnic;
      _filling = false;
      isDirty.value = false;

      AppSnackbar.success(changingPassword
          ? 'Settings saved and password changed'
          : 'Settings saved');
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> cancel() async {
    if (isDirty.value) {
      final ok = await AppDialogs.confirm(
        title: 'Discard changes?',
        message: 'Your unsaved changes will be lost.',
        confirmText: 'Discard',
        isDestructive: true,
      );
      if (ok != true) return;
    }
    Get.back();
  }

  Future<void> logout() async {
    final ok = await AppDialogs.confirm(
      title: 'Log out?',
      message: 'You will need to log in again to use the app.',
      confirmText: 'Log out',
      isDestructive: true,
    );
    if (ok != true) return;

    try {
      await _auth.logout();
      Get.offAllNamed(AppRoutes.adminLogin);
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    }
  }

  @override
  void onClose() {
    for (final c in _watched) {
      c.dispose();
    }
    for (final a in accounts) {
      a.dispose();
    }
    super.onClose();
  }
}