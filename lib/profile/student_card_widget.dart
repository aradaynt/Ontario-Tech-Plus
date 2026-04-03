// OntarioTechPlus - student_card_widget.dart

// Popout window for student card display. Can be used anywhere.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:ontario_tech_plus/profile/profile_model.dart';

// Popup for displaying the student card
class StudentCardDialog extends StatelessWidget {
  const StudentCardDialog({super.key, required this.profile});

  final Profile profile;

  // Build popup for the student card
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // popup background
            const _StudentCardDialogBackground(),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420, maxHeight: 480),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Close button at the top right
                    Row(
                      children: [
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          color: Colors.white,
                          tooltip: "Close",
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      // White card container for holding student card content
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Student Card",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0A3FAF),
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Expanded(
                              child: StudentCardWidget(profile: profile),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Actual student card details for displaying in white box
class StudentCardWidget extends StatelessWidget {
  const StudentCardWidget({super.key, required this.profile});

  final Profile profile;

  // Build the student card content
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Read available space from the dialog
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        // Size the photo and barcode based on available room
        final photoSize = math
            .min(availableWidth * 0.99, math.max(250.0, availableHeight * 0.68))
            .clamp(250.0, 420.0)
            .toDouble();
        final barcodeHeight = math
            .min(74.0, availableHeight * 0.16)
            .clamp(56.0, 74.0)
            .toDouble();

        // Photo section for the student card
        final photoSection = Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: photoSize,
            height: photoSize,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/studentPhotos/sampleStudentPhoto.jpg',
                    fit: BoxFit.fill,
                  ),
                  Container(color: Colors.black.withValues(alpha: 0.14)),
                ],
              ),
            ),
          ),
        );

        // Name and student number section
        final textSection = Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                profile.fullName,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Student Number: ${profile.studentNumber}",
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );

        // Barcode section
        final barcodeSection = Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.45,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: barcodeHeight,
                width: double.infinity,
                child: SfBarcodeGenerator(
                  value: profile.studentNumber,
                  symbology: Code128(),
                  showValue: false,
                  barColor: Colors.black,
                  backgroundColor: Colors.transparent,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                profile.studentNumber,
                style: theme.textTheme.titleMedium?.copyWith(
                  letterSpacing: 3,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );

        // Layout for popup student card
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            photoSection,
            const Spacer(),
            textSection,
            const Spacer(),
            barcodeSection,
            const Spacer(),
          ],
        );
      },
    );
  }
}

// Background for the student card popup
class _StudentCardDialogBackground extends StatelessWidget {
  const _StudentCardDialogBackground();

  // Blue background
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0E56D8), Color(0xFF0A3FAF)],
        ),
      ),
      child: Stack(
        children: [
          // Shapes patterns to add extra style to background
          Positioned.fill(child: CustomPaint(painter: _PatternPainter())),
          // Ontario Tech text at the top
          Positioned(
            left: 24,
            top: 22,
            right: 24,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                  children: [
                    TextSpan(
                      text: 'ONTARIO ',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: 'TECH +',
                      style: TextStyle(color: Color(0xFFFF9A2F)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Painter for popup background pattern
class _PatternPainter extends CustomPainter {
  // Paint repeating background pattern
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    const cell = 72.0;
    for (double y = -cell; y < size.height + cell; y += cell) {
      for (double x = -cell; x < size.width + cell; x += cell) {
        final rect = Rect.fromLTWH(x + 8, y + 8, cell - 16, cell - 16);
        canvas.drawArc(rect, 0.15, 3.8, false, paint);
        canvas.drawLine(
          Offset(x + 10, y + cell * 0.55),
          Offset(x + cell - 10, y + cell * 0.55),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
