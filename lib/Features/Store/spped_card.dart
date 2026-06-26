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
//                           fontWeight: FontWeight.bold,
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
//                       fontWeight: FontWeight.bold,
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
//                       fontWeight: FontWeight.bold,
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

              // Speed + Discount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Expanded(
                    child: CommonText.h3(
                      speedText,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),

                  if (discountText != null) ...[

                    const SizedBox(width: 4),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),

                      decoration: BoxDecoration(
                        color: CommonColor.blue,
                        borderRadius: BorderRadius.circular(6),
                      ),

                      child: CommonText.small(
                        discountText!,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),


              // APR
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const CommonText.small(
                    "APR",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),

                  CommonText.body(
                    aprValue,
                    style: const TextStyle(
                      color: CommonColor.orange,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),


              // Free CPU Power
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const CommonText.small(
                    "Free CPU Power",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),

                  CommonText.body(
                    freeCpuValue,
                    style: const TextStyle(
                      color: CommonColor.orange,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),


              // Price
              CommonText.h3(
                price,
              ),
            ],
          ),
        ),
      ),
    );
  }
}