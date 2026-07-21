import 'package:flutter/material.dart';

class PasswordRequirementsDialog extends StatelessWidget {
  final String password;

  const PasswordRequirementsDialog({Key? key, required this.password})
      : super(key: key);

  bool get hasMinLength => password.length >= 8;
  bool get hasUppercase => RegExp(r'[A-Z]').hasMatch(password);
  bool get hasLowercase => RegExp(r'[a-z]').hasMatch(password);
  bool get hasNumber => RegExp(r'[0-9]').hasMatch(password);
  bool get hasSpecial =>
      RegExp(r'[!@#$%^&*()_+\-=\[\]{};'':"\\|,.<>\/?]').hasMatch(password);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close Button
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () => Navigator.maybePop(context),
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.close_rounded,
                      color: Color(0xFF6B7280), size: 24),
                ),
              ),
            ),

            // Top Icon (Shield with decorations)
            const _TopShieldIcon(),
            const SizedBox(height: 16),

            // Title
            const Text(
              'Strong Password Required',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.w500, fontFamily: 'EBGaramond', fontStyle: FontStyle.italic,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),

            // Subtitle
            const Text(
              'For your security, please follow these requirements',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w500, fontFamily: 'EBGaramond', fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),

            // Rules List
            _buildRuleRow(
              iconText: 'Aa',
              iconBgColor: const Color(0xFFEFF6FF),
              iconTextColor: const Color(0xFF2563EB),
              text: 'At least 8 characters',
              isMet: hasMinLength,
            ),
            _buildDivider(),
            _buildRuleRow(
              iconText: 'A',
              iconBgColor: const Color(0xFFF0FDF4),
              iconTextColor: const Color(0xFF16A34A),
              text: 'At least 1 uppercase letter',
              isMet: hasUppercase,
            ),
            _buildDivider(),
            _buildRuleRow(
              iconText: 'a',
              iconBgColor: const Color(0xFFFFF7ED),
              iconTextColor: const Color(0xFFEA580C),
              text: 'At least 1 lowercase letter',
              isMet: hasLowercase,
            ),
            _buildDivider(),
            _buildRuleRow(
              iconText: '1',
              iconBgColor: const Color(0xFFFAF5FF),
              iconTextColor: const Color(0xFF9333EA),
              text: 'At least 1 number (0-9)',
              isMet: hasNumber,
            ),
            _buildDivider(),
            _buildRuleRow(
              iconText: '@',
              iconBgColor: const Color(0xFFFEF2F2),
              iconTextColor: const Color(0xFFDC2626),
              text: 'At least 1 special character\n(!@#\$%^&* etc.)',
              isMet: hasSpecial,
            ),
            const SizedBox(height: 24),

            // Bottom Info Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.security_rounded,
                        color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stronger password, stronger security.',
                          style: TextStyle(
                              color: Color(0xFF1E3A8A),
                              fontWeight: FontWeight.w500, fontFamily: 'EBGaramond', fontStyle: FontStyle.italic,
                              fontSize: 13),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Keep your account safe and secure.',
                          style: TextStyle(
                              color: Color(0xFF64748B), fontSize: 9.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 16, thickness: 1, color: Color(0xFFF1F5F9));
  }

  Widget _buildRuleRow({
    required String iconText,
    required Color iconBgColor,
    required Color iconTextColor,
    required String text,
    required bool isMet,
  }) {
    // Parse "At least X whatever" so we can bold the number
    // To keep it simple, we'll just bold numbers in the string if it's "8" or "1"
    List<TextSpan> textSpans = [];
    final parts = text.split(RegExp(r'(8|1)'));
    if (parts.length > 1) {
      textSpans.add(TextSpan(text: parts[0]));
      textSpans.add(TextSpan(
          text: text.contains('8') ? '8' : '1',
          style: const TextStyle( color: Color(0xFF1E293B), fontSize: 14)));
      textSpans.add(TextSpan(text: parts[1]));
    } else {
      textSpans.add(TextSpan(text: text));
    }

    return Row(
      children: [
        // Left Icon
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            iconText,
            style: TextStyle(
              color: iconTextColor,
              
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // Text
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 13.5,
                fontWeight: FontWeight.w500, fontFamily: 'EBGaramond', fontStyle: FontStyle.italic,
                height: 1.4,
              ),
              children: textSpans,
            ),
          ),
        ),
        
        // Right Checkmark
        Icon(
          isMet ? Icons.check_circle_outline_rounded : Icons.radio_button_unchecked_rounded,
          color: isMet ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
          size: 22,
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════
// Top Shield Icon with dots and stars
// ═════════════════════════════════════════════
class _TopShieldIcon extends StatelessWidget {
  const _TopShieldIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circles
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
          ),
          
          // Dots and sparkles
          Positioned(left: 10, top: 10, child: _sparkle(const Color(0xFF10B981))),
          Positioned(right: 20, top: 0, child: _dot(4, const Color(0xFF3B82F6))),
          Positioned(right: 10, top: 30, child: _sparkle(const Color(0xFF93C5FD))),
          Positioned(left: 15, bottom: 20, child: _sparkle(const Color(0xFF6EE7B7))),
          Positioned(right: 25, bottom: 15, child: _dot(5, const Color(0xFF10B981))),
          
          // Main Shield
          Container(
            width: 44,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12),
                bottom: Radius.circular(24),
              ),
            ),
            child: const Center(
              child: Icon(Icons.lock_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _sparkle(Color color) => Icon(Icons.auto_awesome_rounded, size: 12, color: color);
}
