// OntarioTechPlus - image_upload_widget.dart

// This is the definition for the popup that allows users to select a profile image to upload
// for their student profile.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ontario_tech_plus/profile/photo_verification.dart';

// Opens profile image upload popup
Future<void> showProfileImageUploadDialog({
  required BuildContext context,
  required Future<bool> Function(XFile imageFile) onUsePhoto,
  required bool Function(String path) isAllowedFileType,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => ProfileImageUploadDialog(
      onUsePhoto: onUsePhoto,
      isAllowedFileType: isAllowedFileType,
    ),
  );
}

// Popup widget for picking and verifying a profile photo.
class ProfileImageUploadDialog extends StatefulWidget {
  const ProfileImageUploadDialog({
    super.key,
    required this.onUsePhoto,
    required this.isAllowedFileType,
  });

  // Called when user wants to confirm use of selected photo.
  final Future<bool> Function(XFile imageFile) onUsePhoto;
  // Checks whether the selected file path is an allowed image type
  final bool Function(String path) isAllowedFileType;

  @override
  State<ProfileImageUploadDialog> createState() =>
      _ProfileImageUploadDialogState();
}

class _ProfileImageUploadDialogState extends State<ProfileImageUploadDialog> {
  // Picker to select image from gallery
  final ImagePicker _imagePicker = ImagePicker();

  // Reuses photo verification rules from photo_verification.dart
  final PhotoVerificationService _photoVerificationService =
      PhotoVerificationService();

  // Stores selected image and latest verification result.
  XFile? _selectedImage;
  PhotoVerificationResult? _verificationResult;

  // Tracks whether the popup is verifying or uploadin
  bool _isVerifying = false;
  bool _isSubmitting = false;

  // True when the popup is verifying photo or uploading
  bool get _isBusy => _isVerifying || _isSubmitting;

  // Let user choose photo from the gallery
  Future<void> _selectPhoto() async {
    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );

    // Ensure image not null, and is of correct type (jpg, png)
    if (pickedImage == null || !mounted) return;
    if (!widget.isAllowedFileType(pickedImage.path)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile image must be a JPG or PNG file.'),
        ),
      );
      return;
    }

    setState(() {
      _selectedImage = pickedImage;
      _verificationResult = null;
    });
  }

  // Runs the verification check on selected photo
  Future<void> _verifyPhoto() async {
    final selectedImage = _selectedImage;
    if (selectedImage == null) return;

    setState(() {
      _isVerifying = true;
      _verificationResult = null;
    });

    final result = await _photoVerificationService.verifyPhoto(
      File(selectedImage.path),
    );

    if (!mounted) return;

    setState(() {
      _verificationResult = result;
      _isVerifying = false;
    });
  }

  // Uses the verified photo and starts uplod
  Future<void> _usePhoto() async {
    final selectedImage = _selectedImage;
    final result = _verificationResult;
    if (selectedImage == null || result == null || !result.isValid) return;

    setState(() {
      _isSubmitting = true;
    });

    final didUpload = await widget.onUsePhoto(selectedImage);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (didUpload) {
      Navigator.of(context).pop();
    }
  }

  // Clear current result for another selection
  void _tryAnotherPhoto() {
    setState(() {
      _selectedImage = null;
      _verificationResult = null;
    });
  }

  // Sends photo for manual review (Currently place holder)
  void _notifyAdministration() {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Administration has been notified for manual review!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build preview when image selected
    final previewImage = _selectedImage != null
        ? FileImage(File(_selectedImage!.path)) as ImageProvider
        : null;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Spacer(),
                  IconButton(
                    onPressed: _isBusy
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Profile Image Selector',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: _selectedImage == null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Text(
                                  'No photo selected yet.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image(
                                image: previewImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildBottomContent(context)),
            ],
          ),
        ),
      ),
    );
  }

  // build the lower half of popup
  Widget _buildBottomContent(BuildContext context) {
    // First state no image selected
    if (_selectedImage == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Requirements:',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          // Stated rules for photo upload
          const Text('1. Photo must be of yourself'),
          const Text('2. The photo background must be plain'),
          const Text('3. You must be centered in this photo'),
          const Text('4. Your eyes must be open'),
          const Text('5. Must be jpg or png format'),
          const Spacer(),
          OutlinedButton(
            onPressed: _isBusy ? null : _selectPhoto,
            child: const Text('Select a photo'),
          ),
        ],
      );
    }

    // Second state image is being verified
    if (_isVerifying) {
      return const Column(
        children: [
          Spacer(),
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Verifying photo...', textAlign: TextAlign.center),
          Spacer(),
        ],
      );
    }

    // Third state - show pass or fail for result from photo_verification.dart
    // and next action buttons
    if (_verificationResult != null) {
      final result = _verificationResult!;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: PhotoVerificationResultCard(result: result),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _isBusy
                ? null
                : result.isValid
                ? _usePhoto
                : _tryAnotherPhoto,
            child: _isSubmitting && result.isValid
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : Text(result.isValid ? 'Use this photo' : 'Try another photo'),
          ),
          if (!result.isValid && result.canNotifyAdministration) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _isBusy ? null : _notifyAdministration,
              child: const Text('Notify Administration'),
            ),
          ],
          if (result.isValid) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
              onPressed: _isBusy ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ],
      );
    }

    // Default state after selecting a photo but b4 any verification
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        FilledButton(
          onPressed: _isBusy ? null : _verifyPhoto,
          child: const Text('Verify'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _isBusy ? null : _selectPhoto,
          child: const Text('Select a different photo'),
        ),
      ],
    );
  }
}
