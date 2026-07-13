import 'package:flutter/material.dart';
import '../../Utility/common_color.dart';
import '../../Utility/font_style.dart';

class JoinReferralBottomSheet extends StatefulWidget {
  const JoinReferralBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const JoinReferralBottomSheet(),
    );
  }

  @override
  State<JoinReferralBottomSheet> createState() => _JoinReferralBottomSheetState();
}

class _JoinReferralBottomSheetState extends State<JoinReferralBottomSheet> {
  final TextEditingController _codeController = TextEditingController();
  bool _isApplied = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            if (!_isApplied) ...[
              const Text(
                "Join Referral",
                style: CommonFontStyles.heading2,
              ),
              const SizedBox(height: 24),
              Text(
                "Got a Invite Code?\nEnter your friend's referral details\nto unlock your signup bonus!",
                textAlign: TextAlign.center,
                style: CommonFontStyles.body.copyWith(height: 1.5),
              ),
              const SizedBox(height: 32),
              
              // Text Field
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _codeController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Enter Referral Code or Link",
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.content_paste_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 48),
              const Text(
                "Code applied!\nYou were invited by Raj",
                textAlign: TextAlign.center,
                style: CommonFontStyles.heading3,
              ),
              const SizedBox(height: 48),
            ],
            
            const SizedBox(height: 32),
            
            // Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (!_isApplied) {
                    // TODO: call API to apply code
                    setState(() {
                      _isApplied = true;
                    });
                  } else {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CommonColor.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  _isApplied ? "Continue" : "Apply Code",
                  style: CommonFontStyles.heading3.copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
