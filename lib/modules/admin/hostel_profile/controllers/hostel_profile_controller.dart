import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/exceptions/exception_handler.dart';
import '../../../../core/network/network_manager.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/hostel_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/hostel_repository.dart';
import '../../../../shared/popups/app_dialogs.dart';
import '../../../../shared/popups/app_snackbar.dart';

class HostelProfileController extends GetxController {
  final HostelRepository _repo;
  final AuthRepository _auth;
  HostelProfileController(this._repo, this._auth);

  static const maxImages = 8;

  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  final images = <String>[].obs;
  final amenities = <String>[].obs;

  final isLoaded = false.obs;
  final isLoading = true.obs;
  final isSaving = false.obs;
  final isUploading = false.obs;
  final errorMessage = RxnString();

  final _picker = ImagePicker();
  HostelModel? _original;

  @override
  void onReady() {
    super.onReady();
    load();
  }

  String _priceText(double v) => v == 0 ? '' : v.toStringAsFixed(0);

  void _fill(HostelModel h) {
    _original = h;
    nameCtrl.text = h.name;
    addressCtrl.text = h.address;
    cityCtrl.text = h.city;
    priceCtrl.text = _priceText(h.monthlyPrice);
    phoneCtrl.text = h.contactNumber;
    emailCtrl.text = h.email;
    descCtrl.text = h.description;
    images.assignAll(h.images);
    amenities.assignAll(h.amenities);
    isLoaded.value = true;
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      await NetworkManager.instance.ensureConnected();
      _fill(await _repo.getHostel(_auth.currentUid ?? ''));
    } catch (e, s) {
      errorMessage.value = ExceptionHandler.message(e, s);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImages() async {
    final remaining = maxImages - images.length;
    if (remaining <= 0) {
      AppSnackbar.warning('You can add up to $maxImages images.');
      return;
    }

    try {
      final picked = await _picker.pickMultiImage(
        imageQuality: 75, // size kam, upload tez
        maxWidth: 1280,
      );
      if (picked.isEmpty) return;

      await NetworkManager.instance.ensureConnected();
      isUploading.value = true;

      for (final x in picked.take(remaining)) {
        final url = await _repo.uploadImage(File(x.path));
        images.add(url);
      }
      if (picked.length > remaining) {
        AppSnackbar.info('Only $maxImages images are allowed.');
      }
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    } finally {
      isUploading.value = false;
    }
  }

  void removeImage(int index) => images.removeAt(index);

  Future<void> addAmenity() async {
    final value = await AppDialogs.prompt(
      title: 'Add amenity',
      hint: 'e.g. WiFi, Laundry',
    );
    final name = value?.trim();
    if (name == null || name.isEmpty) return;

    if (amenities.any((a) => a.toLowerCase() == name.toLowerCase())) {
      AppSnackbar.warning('$name is already added.');
      return;
    }
    amenities.add(Formatters.capitalize(name));
  }

  void removeAmenity(String name) => amenities.remove(name);

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    final base = _original;
    if (base == null) return;

    try {
      isSaving.value = true;
      await NetworkManager.instance.ensureConnected();

      final updated = base.copyWith(
        name: nameCtrl.text.trim(),
        address: addressCtrl.text.trim(),
        city: cityCtrl.text.trim(),
        monthlyPrice: double.parse(priceCtrl.text.trim()),
        contactNumber: phoneCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        description: descCtrl.text.trim(),
        images: List<String>.of(images),
        amenities: List<String>.of(amenities),
      );

      await _repo.updateHostel(updated);
      _original = updated;
      AppSnackbar.success('Hostel profile updated');
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    } finally {
      isSaving.value = false;
    }
  }

  bool get _hasChanges {
    final o = _original;
    if (o == null) return false;
    return nameCtrl.text.trim() != o.name ||
        addressCtrl.text.trim() != o.address ||
        cityCtrl.text.trim() != o.city ||
        priceCtrl.text.trim() != _priceText(o.monthlyPrice) ||
        phoneCtrl.text.trim() != o.contactNumber ||
        emailCtrl.text.trim() != o.email ||
        descCtrl.text.trim() != o.description ||
        !listEquals(images, o.images) ||
        !listEquals(amenities, o.amenities);
  }

  Future<void> cancel() async {
    if (_hasChanges) {
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

  @override
  void onClose() {
    nameCtrl.dispose();
    addressCtrl.dispose();
    cityCtrl.dispose();
    priceCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }
}