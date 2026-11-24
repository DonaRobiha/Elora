
import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get light {
    final cs=ColorScheme.fromSeed(seedColor:eloraPrimary,brightness:Brightness.light).copyWith(primary:eloraPrimary,secondary:eloraPrimary,surface:eloraCard);
    return ThemeData(useMaterial3:true,colorScheme:cs,scaffoldBackgroundColor:eloraBackground,appBarTheme:const AppBarTheme(backgroundColor:eloraPrimary,foregroundColor:Colors.white,elevation:0),inputDecorationTheme:_inputs(Colors.white),filledButtonTheme:FilledButtonThemeData(style:FilledButton.styleFrom(backgroundColor:eloraPrimary,foregroundColor:Colors.white,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)))));
  }
  static ThemeData get dark {
    final cs=ColorScheme.fromSeed(seedColor:eloraPrimary,brightness:Brightness.dark).copyWith(primary:const Color(0xFF55C9BE),secondary:const Color(0xFF55C9BE),surface:const Color(0xFF162220));
    return ThemeData(useMaterial3:true,colorScheme:cs,scaffoldBackgroundColor:const Color(0xFF0D1514),appBarTheme:const AppBarTheme(backgroundColor:Color(0xFF0D1514),foregroundColor:Colors.white,elevation:0),cardTheme:const CardThemeData(color:Color(0xFF162220)),inputDecorationTheme:_inputs(const Color(0xFF162220)),filledButtonTheme:FilledButtonThemeData(style:FilledButton.styleFrom(backgroundColor:const Color(0xFF0D8A7D),foregroundColor:Colors.white,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)))));
  }
  static InputDecorationTheme _inputs(Color fill)=>InputDecorationTheme(filled:true,fillColor:fill,contentPadding:const EdgeInsets.symmetric(horizontal:14,vertical:13),border:OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(12)),borderSide:BorderSide.none),enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(12)),borderSide:BorderSide(color:eloraInput)),focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(12)),borderSide:const BorderSide(color:eloraPrimary,width:1.4)));
}
