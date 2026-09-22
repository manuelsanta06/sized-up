import 'package:flutter/material.dart';

class NoteColorOption {
  const NoteColorOption({required this.label,required this.value,this.isCustom=false});
  final String label;
  final int value;
  final bool isCustom;
}

const noteColorOptions = [
  NoteColorOption(label: 'Violet' , value: 0xFF65558F),
  NoteColorOption(label: 'Blue'   , value: 0xFF4F6384),
  NoteColorOption(label: 'Green'  , value: 0xFF486A56),
  NoteColorOption(label: 'Amber'  , value: 0xFF80622D),
  NoteColorOption(label: 'Red'    , value: 0xFF86504E),
  NoteColorOption(label: 'Custom' , value: 0xFF8D6DB5,isCustom:true),
];

Color noteColorFromValue(int value) => Color(value);
