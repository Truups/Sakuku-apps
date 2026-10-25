import 'package:flutter/material.dart';
import 'package:sakuku/assets/color_apps.dart';
import 'package:sakuku/widgets/curve_background.dart';

class InformationPage extends StatelessWidget {
  const InformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            children: [
              ClipPath(
                clipper: HeaderClipper(),
                child: Container(
                  height: 340,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: AppColors.balanceBlue
                  ),
                ),
              ),
              SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Informasi",
                          style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w700
                          ) ,
                        ),
                        const SizedBox(height: 300,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Made With Flutter",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w700,
                                fontSize: 32,
                                color: AppColors.textPrimary
                              ) ,
                            )
                          ],
                        )
                      ],
                    ),
                  )
              )
            ],
          ),
        )
    );
  }
}
