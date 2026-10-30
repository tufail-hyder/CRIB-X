import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/exceptions/exception_handler.dart';
import '../../../../core/network/network_manager.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/student_profile_repository.dart';
import '../../../../shared/popups/app_dialogs.dart';
import '../../../../shared/popups/app_snackbar.dart';
import '../widgets/student_dialog_widget.dart';

class StudentProfileController extends GetxController {
  final StudentProfileRepository _repo;
  final AuthRepository _auth;
  StudentProfileController(this._repo, this._auth);

  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final currentPassCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  final photoUrl = RxnString();

  final isLoaded = false.obs;
  final isLoading = true.obs;
  final isSaving = false.obs;
  final isUploadingPhoto = false.obs;
  final isDirty = false.obs;
  final errorMessage = RxnString();

  final _picker = ImagePicker();
  StudentProfile? _original;
  bool _filling = false;

  List<TextEditingController> get _watched => [
    nameCtrl,
    phoneCtrl,
    cityCtrl,
    currentPassCtrl,
    newPassCtrl,
    confirmPassCtrl,
  ];

  @override
  void onInit() {
    super.onInit();
    for (final c in _watched) {
      c.addListener(_markDirty);
    }
  }

  @override
  void onReady() {
    super.onReady();
    load();
  }

  void _markDirty() {
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

  void _fill(StudentProfile p) {
    _original = p;
    _filling = true;
    nameCtrl.text = p.name;
    emailCtrl.text = p.email;
    phoneCtrl.text = p.phone;
    cityCtrl.text = p.city;
    photoUrl.value = p.photoUrl;
    currentPassCtrl.clear();
    newPassCtrl.clear();
    confirmPassCtrl.clear();
    _filling = false;
    isDirty.value = false;
    isLoaded.value = true;
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
      _markDirty();
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  // ------------------------------------------------------------------
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

  // ------------------------------------------------------------------
  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isSaving.value = true;
      await NetworkManager.instance.ensureConnected();

      // Password pehle: galat current password par kuch save na ho
      final changingPassword = _wantsPasswordChange;
      if (changingPassword) {
        await _auth.changePassword(currentPassCtrl.text, newPassCtrl.text);
      }

      await _repo.save(
        _auth.currentUid ?? '',
        name: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        city: cityCtrl.text.trim(),
        photoUrl: photoUrl.value,
      );

      final base = _original;
      _fill(StudentProfile(
        name: nameCtrl.text.trim(),
        email: base?.email ?? emailCtrl.text,
        phone: phoneCtrl.text.trim(),
        city: cityCtrl.text.trim(),
        photoUrl: photoUrl.value,
      ));

      await StudentDialogs.success(
        message: changingPassword
            ? 'Profile and password updated'
            : 'Profile updated',
      );
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> cancel() async {
    if (!isDirty.value) {
      Get.offAllNamed(AppRoutes.studentHome);
      return;
    }
    final ok = await AppDialogs.confirm(
      title: 'Discard changes?',
      message: 'Your unsaved changes will be lost.',
      confirmText: 'Discard',
      isDestructive: true,
    );
    if (ok != true) return;

    final base = _original;
    if (base != null) _fill(base);
  }

  Future<void> logout() async {
    if (!await StudentDialogs.confirmLogout()) return;

    try {
      await _auth.logout();
      Get.offAllNamed(AppRoutes.studentLogin);
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    }
  }

  void openNotifications() => AppSnackbar.info('No new notifications.');

  @override
  void onClose() {
    for (final c in _watched) {
      c.dispose();
    }
    emailCtrl.dispose();
    super.onClose();
  }
}