// OntarioTechPlus - photo_verification.dart

// This is the logic for photo verification based on content from lectures for ML

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

// Handles the ML checks for photo verification.
class PhotoVerificationService {
  // Threshold for how close the face needs to be to the center of the image
  static const double _centerTolerancePercent = 0.18;
  // Threshold for the eye-open score needed to pass
  static const double _eyeOpenThreshold = 0.5;
  // Threshold needed to identify the image as an animal
  static const double _animalLabelThreshold = 0.7;
  // Threshold needed to treat the image as human
  static const double _humanLabelThreshold = 0.55;
  // Face landmarks required to consider it a human face
  static final List<FaceLandmarkType> _requiredHumanLandmarks = [
    FaceLandmarkType.leftEye,
    FaceLandmarkType.rightEye,
    FaceLandmarkType.noseBase,
    FaceLandmarkType.leftMouth,
    FaceLandmarkType.rightMouth,
  ];

  // Animal keywords
  static const Set<String> _animalKeywords = {
    'dog',
    'puppy',
    'canine',
    'animal',
    'pet',
    'mammal',
    'breed',
  };

  // Human keywords
  static const Set<String> _humanKeywords = {
    'person',
    'human',
    'face',
    'forehead',
    'nose',
    'chin',
    'hairstyle',
  };

  // Run face verification on the image
  Future<PhotoVerificationResult> verifyPhoto(File imageFile) async {
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
      ),
    );
    final imageLabeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.5),
    );

    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final List<Face> faces = await faceDetector.processImage(inputImage);
      final List<ImageLabel> imageLabels = await imageLabeler.processImage(
        inputImage,
      );
      final ui.Size imageDimension = await _readImageDimensions(imageFile);

      return _buildVerificationResult(
        faces: faces,
        imageLabels: imageLabels,
        imageDimension: imageDimension,
      );
    } catch (error) {
      return PhotoVerificationResult.error(
        'Could not analyze this image: $error',
      );
    } finally {
      await faceDetector.close();
      await imageLabeler.close();
    }
  }

  // Reads image dimensions to check for center
  Future<ui.Size> _readImageDimensions(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final ui.Image decodedImage = await decodeImageFromList(bytes);
    return ui.Size(
      decodedImage.width.toDouble(),
      decodedImage.height.toDouble(),
    );
  }

  // Builds pass or fail result from the image face data
  PhotoVerificationResult _buildVerificationResult({
    required List<Face> faces,
    required List<ImageLabel> imageLabels,
    required ui.Size imageDimension,
  }) {
    // Get the image label before building final result
    final _LabelSignals labelSignals = _extractLabelSignals(imageLabels);

    // Fail if no human face was found in the image.
    if (faces.isEmpty) {
      return PhotoVerificationResult(
        isValid: false,
        summary: 'Fail',
        details: 'No human face was found in this photo',
      );
    }

    // Fail if more than one face was found.
    if (faces.length > 1) {
      return PhotoVerificationResult(
        isValid: false,
        summary: 'Fail',
        details:
            'More than one face was detected. Please ensure you are the only one in the photo',
      );
    }

    // Use detected face for the rest of checks
    final Face face = faces.first;

    // Bounding box around detected face
    final Rect box = face.boundingBox;

    // Center point of the full image
    final double imageCenterX = imageDimension.width / 2;
    final double imageCenterY = imageDimension.height / 2;

    // Center point of the detected face
    final double faceCenterX = box.left + (box.width / 2);
    final double faceCenterY = box.top + (box.height / 2);

    // Horizontal distance from face center to image center
    final double normalizedOffsetX =
        (faceCenterX - imageCenterX).abs() / imageDimension.width;

    // Vertical distance from face center to image center
    final double normalizedOffsetY =
        (faceCenterY - imageCenterY).abs() / imageDimension.height;

    // Check if the face is close enough to the center
    final bool isCentered =
        normalizedOffsetX <= _centerTolerancePercent &&
        normalizedOffsetY <= _centerTolerancePercent;

    // ML score for left eye being open
    final double? leftEyeOpenProbability = face.leftEyeOpenProbability;

    // ML score for right eye being open
    final double? rightEyeOpenProbability = face.rightEyeOpenProbability;

    // Check if required human landmarks were found
    final bool hasRequiredHumanLandmarks = _hasRequiredHumanLandmarks(face);

    // Check if both eye scores are available
    final bool hasEyeClassificationData =
        leftEyeOpenProbability != null && rightEyeOpenProbability != null;

    // Check if the face looks like a human face
    final bool isHumanFaceDetected =
        hasRequiredHumanLandmarks &&
        hasEyeClassificationData &&
        labelSignals.looksHuman;

    // Check if both eyes appear open enough
    final bool areEyesOpen =
        hasEyeClassificationData &&
        leftEyeOpenProbability >= _eyeOpenThreshold &&
        rightEyeOpenProbability >= _eyeOpenThreshold;

    // Final pass rule: human face, centered, and eyes open.
    final bool isValid = isHumanFaceDetected && isCentered && areEyesOpen;

    // Show the manual review button for eye-related failures for accessibility
    final bool canNotifyAdministration =
        !isValid &&
        isHumanFaceDetected &&
        (!hasEyeClassificationData || !areEyesOpen);

    // Return the final verification result
    return PhotoVerificationResult(
      isValid: isValid,
      summary: isValid ? 'Pass' : 'Fail',
      details: _buildDetailsMessage(
        isHumanFaceDetected: isHumanFaceDetected,
        hasRequiredHumanLandmarks: hasRequiredHumanLandmarks,
        animalLikely: labelSignals.animalLikely,
        isCentered: isCentered,
        areEyesOpen: areEyesOpen,
        hasEyeData: hasEyeClassificationData,
      ),
      canNotifyAdministration: canNotifyAdministration,
    );
  }

  String _buildDetailsMessage({
    required bool isHumanFaceDetected,
    required bool hasRequiredHumanLandmarks,
    required bool animalLikely,
    required bool isCentered,
    required bool areEyesOpen,
    required bool hasEyeData,
  }) {
    // Fail because the image did not pass the human face check.
    if (!isHumanFaceDetected) {
      // Fail - image looks like an animal instead of person
      if (animalLikely) {
        return 'This image appears to be an animal';
      }

      // Fail - not enough human face landmarks.
      if (!hasRequiredHumanLandmarks) {
        return 'Face detected, but does not look human.';
      }

      // Fail - eye data not reliable enough
      return 'Both eyes must be clearly visible in the photo.';
    }

    // Success - photo passed the main checks
    if (isCentered && areEyesOpen) {
      return 'This photo meets all of the requirements!';
    }

    // Fail - eye open data could not confirmed
    if (!hasEyeData) {
      return 'Please ensure both your eyes are open.';
    }

    // Fail - face is off center and the eyes not opn enough
    if (!isCentered && !areEyesOpen) {
      return 'Face detected, but it is not close enough to the center and eyes are not open enough.';
    }

    // Fail because the face is not centered enough.
    if (!isCentered) {
      return 'Face must be near the center of the photo';
    }

    // Fail - eyes not open enough
    return 'Face detected and is centered, but both eyes do not appear open. If this is an accessibility issue, please contact administration for manual review';
  }

  // Checks whether the required human landmarks were found
  bool _hasRequiredHumanLandmarks(Face face) {
    for (final FaceLandmarkType type in _requiredHumanLandmarks) {
      if (face.landmarks[type] == null) {
        return false;
      }
    }

    return true;
  }

  // helper to pull out the human and animal labels from the image labeling results
  _LabelSignals _extractLabelSignals(List<ImageLabel> imageLabels) {
    String? animalLabel;
    double? animalConfidence;
    String? humanLabel;
    double? humanConfidence;

    for (final ImageLabel label in imageLabels) {
      final String normalized = label.label.toLowerCase();

      if (_animalKeywords.contains(normalized) &&
          label.confidence >= _animalLabelThreshold &&
          (animalConfidence == null || label.confidence > animalConfidence)) {
        animalLabel = label.label;
        animalConfidence = label.confidence;
      }

      if (_humanKeywords.contains(normalized) &&
          label.confidence >= _humanLabelThreshold &&
          (humanConfidence == null || label.confidence > humanConfidence)) {
        humanLabel = label.label;
        humanConfidence = label.confidence;
      }
    }

    final bool animalLikely = animalLabel != null;
    final bool humanLikely = humanLabel != null;

    return _LabelSignals(
      animalLikely: animalLikely,
      humanLikely: humanLikely,
      animalLabel: animalLabel,
      animalConfidence: animalConfidence,
      humanLabel: humanLabel,
      humanConfidence: humanConfidence,
    );
  }
}

// Store final result
class PhotoVerificationResult {
  const PhotoVerificationResult({
    required this.isValid,
    required this.summary,
    required this.details,
    this.canNotifyAdministration = false,
  });

  const PhotoVerificationResult.error(String message)
    : this(isValid: false, summary: 'Fail', details: message);

  final bool isValid;
  final String summary;
  final String details;
  final bool canNotifyAdministration;
}

// Simple result card to show pass/fail and the user-friendly message.
class PhotoVerificationResultCard extends StatelessWidget {
  const PhotoVerificationResultCard({super.key, required this.result});

  final PhotoVerificationResult result;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = result.isValid ? Colors.green : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  result.isValid ? Icons.verified : Icons.error_outline,
                  color: statusColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.summary,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(result.details, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// Helper model for the image label checks.
class _LabelSignals {
  const _LabelSignals({
    required this.animalLikely,
    required this.humanLikely,
    this.animalLabel,
    this.animalConfidence,
    this.humanLabel,
    this.humanConfidence,
  });

  final bool animalLikely;
  final bool humanLikely;
  final String? animalLabel;
  final double? animalConfidence;
  final String? humanLabel;
  final double? humanConfidence;

  bool get looksHuman => !animalLikely || humanLikely;
}
