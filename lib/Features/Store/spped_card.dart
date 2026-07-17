// import 'package:flutter/material.dart';
//
// import '../../Utility/black_card.dart';
// import '../../Utility/common_color.dart';
// import '../../Utility/common_text.dart';
//
// class SpeedCard extends StatelessWidget {
//   final String speedText;
//   final String aprValue;
//   final String freeCpuValue;
//   final String price;
//   final bool isSelected;
//   final String? discountText;
//   final VoidCallback onTap;
//
//   const SpeedCard({
//     super.key,
//     required this.speedText,
//     required this.aprValue,
//     required this.freeCpuValue,
//     required this.price,
//     required this.isSelected,
//     required this.onTap,
//     this.discountText,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: GradientBorderContainer(
//           height: 150,
//           borderRadius: 20,
//           strokeWidth: 1.5,
//           backgroundColor: CommonColor.greyCard,
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//           gradient: isSelected
//               ? const LinearGradient(
//             colors: [CommonColor.blue, CommonColor.blue],
//           )
//               : null,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: CommonText.h3(
//                       speedText,
//                       style: const TextStyle(
//                         fontSize: 15,
//                       ),
//                     ),
//                   ),
//                   if (discountText != null) ...[
//                     const SizedBox(width: 4),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 6,
//                         vertical: 2,
//                       ),
//                       decoration: BoxDecoration(
//                         color: CommonColor.blue,
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: CommonText.small(
//                         discountText!,
//                         style: const TextStyle(
//                           fontSize: 9,
//                           fontWeight: FontWeight.normal,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const CommonText.small(
//                     "APR",
//                     style: TextStyle(
//                       color: Colors.grey,
//                       fontSize: 10,
//                     ),
//                   ),
//                   CommonText.body(
//                     aprValue,
//                     style: const TextStyle(
//                       color: CommonColor.orange,
//                       fontSize: 13,
//                       fontWeight: FontWeight.normal,
//                     ),
//                   ),
//                 ],
//               ),
//
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const CommonText.small(
//                     "Free CPU Power",
//                     style: TextStyle(
//                       color: Colors.grey,
//                       fontSize: 10,
//                     ),
//                   ),
//                   CommonText.body(
//                     freeCpuValue,
//                     style: const TextStyle(
//                       color: CommonColor.orange,
//                       fontSize: 13,
//                       fontWeight: FontWeight.normal,
//                     ),
//                   ),
//                 ],
//               ),
//
//               CommonText.h3(
//                 price,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

import '../../Utility/black_card.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_text.dart';

class SpeedCard extends StatelessWidget {
  final String speedText;
  final String aprValue;
  final String freeCpuValue;
  final String price;
  final bool isSelected;
  final String? discountText;
  final VoidCallback onTap;

  const SpeedCard({
    super.key,
    required this.speedText,
    required this.aprValue,
    required this.freeCpuValue,
    required this.price,
    this.isSelected = false, // optional now
    required this.onTap,
    this.discountText,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: GradientBorderContainer(
          height: 150,
          borderRadius: 20,
          strokeWidth: 1.5,
          backgroundColor: CommonColor.greyCard,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          gradient: isSelected
              ? const LinearGradient(
            colors: [
              CommonColor.blue,
              CommonColor.blue,
            ],
          )
              : null,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [

              // Speed
              CommonText.h3(
                speedText,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 2),

              // Estimate Profit
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CommonText.small(
                    "Estimate Profit",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  CommonText.body(
                    discountText ?? "",
                    style: const TextStyle(
                      color: CommonColor.orange,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Plan
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CommonText.small(
                    "Plan",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  CommonText.body(
                    speedText.contains("10 GH/s") ? "Free Plan" : "Paid Plan",
                    style: const TextStyle(
                      color: CommonColor.orange,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 2),

              // Price
              CommonText.h3(
                price,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
