import 'dart:math' as math;

import 'package:flutter/material.dart';
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
            // Branded popup background
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
                      // White card container holding the student card content
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

// Widget for displaying the student card inside the popup
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
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final hasBoundedHeight = constraints.maxHeight.isFinite;
        final availableHeight = hasBoundedHeight
            ? constraints.maxHeight
            : 520.0;

        // Size the photo and barcode based on available room
        final photoSize = math
            .min(availableWidth * 0.99, math.max(250.0, availableHeight * 0.68))
            .clamp(250.0, 420.0)
            .toDouble();
        final barcodeHeight = math
            .min(52.0, availableHeight * 0.1)
            .clamp(34.0, 52.0)
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

        // Barcode section at the bottom of the card
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
              ClipRect(
                child: SizedBox(
                  height: barcodeHeight,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _StudentBarcodePainter(profile.studentNumber),
                  ),
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

        // Use a simple stacked layout when height is unbounded
        if (!hasBoundedHeight) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              photoSection,
              const SizedBox(height: 12),
              textSection,
              const SizedBox(height: 10),
              barcodeSection,
            ],
          );
        }

        // Spread sections evenly when the dialog gives a fixed height
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

  // Build the blue popup background
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
          // Light repeating pattern behind the popup
          Positioned.fill(child: CustomPaint(painter: _OtPatternPainter())),
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

// Painter for the popup background pattern
class _OtPatternPainter extends CustomPainter {
  // Paint the repeating background pattern
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

// Helper model for barcode sizing
class _BarcodeMetrics {
  const _BarcodeMetrics({
    required this.quietZone,
    required this.baseUnit,
    required this.totalWidth,
  });

  final double quietZone;
  final double baseUnit;
  final double totalWidth;
}

// Painter used to draw the student number barcode
class _StudentBarcodePainter extends CustomPainter {
  const _StudentBarcodePainter(this.studentNumber);

  final String studentNumber;

  static const List<List<int>> _patterns = [
    [1, 1, 1, 2, 2, 1],
    [2, 1, 1, 1, 2, 2],
    [1, 2, 1, 1, 2, 2],
    [2, 2, 1, 1, 1, 2],
    [1, 1, 2, 2, 1, 2],
    [2, 1, 2, 1, 1, 2],
    [1, 2, 2, 1, 1, 2],
    [1, 1, 2, 1, 2, 2],
    [2, 1, 1, 2, 1, 2],
    [1, 2, 1, 2, 1, 2],
  ];

  // Calculate how wide each barcode unit should be
  _BarcodeMetrics _metricsFor(Size size) {
    final unitCount = _totalUnits(studentNumber);
    final quietZone = math.max(4.0, size.width * 0.04);
    final usableWidth = math.max(1.0, size.width - (quietZone * 2));
    final baseUnit = usableWidth / unitCount;
    return _BarcodeMetrics(
      quietZone: quietZone,
      baseUnit: baseUnit,
      totalWidth: quietZone * 2 + (unitCount * baseUnit),
    );
  }

  // Count the total number of barcode units needed
  static double _totalUnits(String studentNumber) {
    var units = 0.0;

    // Start guard: 3 bars and 3 spaces.
    units += 6;

    for (final rune in studentNumber.runes) {
      final digit = int.tryParse(String.fromCharCode(rune)) ?? 0;
      final pattern = _patterns[digit];
      for (final value in pattern) {
        units += value;
      }
      units += 1; // inter-digit space
    }

    // End guard: 3 bars and 3 spaces.
    units += 6;

    return units;
  }

  // Paint the barcode using the student number digits
  @override
  void paint(Canvas canvas, Size size) {
    final metrics = _metricsFor(size);
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final usableHeight = size.height;
    var x = metrics.quietZone;

    void drawBar(double units, double heightFactor) {
      final width = metrics.baseUnit * units;
      final height = usableHeight * heightFactor;
      final top = usableHeight - height;
      canvas.drawRect(Rect.fromLTWH(x, top, width, height), paint);
      x += width;
    }

    void addSpace(double units) {
      x += metrics.baseUnit * units;
    }

    for (var i = 0; i < 3; i++) {
      drawBar(1, 0.98);
      addSpace(1);
    }

    for (final rune in studentNumber.runes) {
      final digit = int.tryParse(String.fromCharCode(rune)) ?? 0;
      final pattern = _patterns[digit];

      for (var i = 0; i < pattern.length; i++) {
        if (i.isEven) {
          final heightFactor = 0.58 + (0.08 * ((digit + i) % 4));
          drawBar(pattern[i].toDouble(), math.min(heightFactor, 0.96));
        } else {
          addSpace(pattern[i].toDouble());
        }
      }

      addSpace(1);
    }

    for (var i = 0; i < 3; i++) {
      drawBar(1, 0.98);
      addSpace(1);
    }

    final overflow = x - metrics.totalWidth;
    if (overflow > 0.5) {
      final coverPaint = Paint()..color = Colors.white;
      canvas.drawRect(
        Rect.fromLTWH(size.width - overflow, 0, overflow, size.height),
        coverPaint,
      );
    }
  }

  // Repaint only if the student number changes
  @override
  bool shouldRepaint(covariant _StudentBarcodePainter oldDelegate) {
    return oldDelegate.studentNumber != studentNumber;
  }
}
