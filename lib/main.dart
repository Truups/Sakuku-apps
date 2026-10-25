import "package:flutter/material.dart";
import "package:sakuku/pages/mainshell_page.dart";


void main(){
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Start Page",
      debugShowCheckedModeBanner: false,
      home: MainShellPage(),
    );
  }
}