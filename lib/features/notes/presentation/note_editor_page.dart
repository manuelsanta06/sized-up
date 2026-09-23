import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

import '../application/note_providers.dart';
import '../data/models/note.dart';
import 'note_palette.dart';

class NoteEditorPage extends ConsumerStatefulWidget{
  const NoteEditorPage({this.note,super.key});
  final Note? note;
  @override
  ConsumerState<NoteEditorPage> createState()=>_NoteEditorPageState();
}

class _NoteEditorPageState extends ConsumerState<NoteEditorPage>{
  final _formKey=GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late int _selectedColorValue;
  bool get _isEditing=>widget.note!=null;
  @override
  void initState(){
    super.initState();
    final note=widget.note;
    _titleController=TextEditingController(text:note?.title??'');
    _contentController=TextEditingController(text:note?.content??'');
    _selectedColorValue=note?.colorValue??Note.defaultColorValue;
  }
  @override
  void dispose(){
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context){
    final accentColor=noteColorFromValue(_selectedColorValue);
    final baseTheme=Theme.of(context);
    final colorScheme=ColorScheme.fromSeed(seedColor:accentColor,brightness:Brightness.dark);
    final fieldBorder=OutlineInputBorder(borderRadius:BorderRadius.circular(18));
    final theme=baseTheme.copyWith(
      colorScheme:colorScheme,
      scaffoldBackgroundColor:colorScheme.surface,
      inputDecorationTheme:baseTheme.inputDecorationTheme.copyWith(
        filled:true,
        fillColor:colorScheme.surfaceContainerHigh,
        border:fieldBorder,
        enabledBorder:fieldBorder.copyWith(borderSide:BorderSide(color:colorScheme.outline)),
        focusedBorder:fieldBorder.copyWith(borderSide:BorderSide(color:colorScheme.primary,width:2)),
        errorBorder:fieldBorder.copyWith(borderSide:BorderSide(color:colorScheme.error)),
        focusedErrorBorder:fieldBorder.copyWith(borderSide:BorderSide(color:colorScheme.error,width:2)),
      ),
    );
    return Theme(
      data:theme,
      child:Scaffold(
        appBar:AppBar(
          title:Text(_isEditing?'Edit note':'New note'),
          actions:[
            _SaveButton(isSaving:ref.watch(noteEditorControllerProvider).isLoading,onPressed:_save),
            const SizedBox(width:8),
          ],
        ),
        body:Form(
          key:_formKey,
          child:ListView(
            padding:const EdgeInsets.fromLTRB(20,12,20,32),
            children:[
              TextFormField(
                controller:_titleController,
                textCapitalization:TextCapitalization.sentences,
                style:baseTheme.textTheme.headlineSmall,
                decoration:const InputDecoration(labelText:'Title',hintText:'Give your note a title'),
                validator:(value){
                  if(value==null||value.trim().isEmpty)return'A title is required.';
                  return null;
                },
              ),
              const SizedBox(height:20),
              TextFormField(
                controller:_contentController,
                textCapitalization:TextCapitalization.sentences,
                minLines:12,
                maxLines:null,
                decoration:const InputDecoration(labelText:'Content',alignLabelWithHint:true,hintText:'Write whatever you want to remember.'),
              ),
              const SizedBox(height:28),
              const _SectionLabel(label:'Tags'),
              const SizedBox(height:10),
              const _ComingSoonChip(),
              const SizedBox(height:28),
              const _SectionLabel(label:'Color'),
              const SizedBox(height:12),
              _NoteColorSelector(
                selectedValue:_selectedColorValue,
                onSelected:(value)=>setState(()=>_selectedColorValue=value),
                onCustomSelected:_selectCustomColor,
              ),
              const SizedBox(height:20),
              _LastEditedLabel(date:widget.note?.updatedAt),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _save()async{
    if(!_formKey.currentState!.validate())return;
    final note=widget.note??Note();
    note.title=_titleController.text.trim();
    note.content=_contentController.text.trim();
    note.colorValue=_selectedColorValue;
    final saved=await ref.read(noteEditorControllerProvider.notifier).save(note);
    if(!mounted)return;
    if(saved){
      Navigator.of(context).pop();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('The note could not be saved.')));
  }
  Future<void> _selectCustomColor()async{
    final color=await showColorPickerDialog(
      context,
      noteColorFromValue(_selectedColorValue),
      title:const Text('Custom color'),
      pickersEnabled:const <ColorPickerType,bool>{
        ColorPickerType.both:false,
        ColorPickerType.primary:false,
        ColorPickerType.accent:false,
        ColorPickerType.bw:false,
        ColorPickerType.custom:false,
        ColorPickerType.wheel:true,
      },
      enableOpacity:false,
      showColorCode:true,
      wheelDiameter:200,
      actionButtons:const ColorPickerActionButtons(dialogActionButtons:true),
    );
    if(!mounted)return;
    setState(()=>_selectedColorValue=color.toARGB32());
  }
}

class _SaveButton extends StatelessWidget{
  const _SaveButton({required this.isSaving,required this.onPressed});
  final bool isSaving;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context)=>TextButton(onPressed:isSaving?null:onPressed,child:isSaving?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)):const Text('Save'));
}

class _SectionLabel extends StatelessWidget{
  const _SectionLabel({required this.label});
  final String label;
  @override
  Widget build(BuildContext context){
    final theme=Theme.of(context);
    return Text(label,style:theme.textTheme.labelLarge?.copyWith(color:theme.colorScheme.onSurfaceVariant,fontWeight:FontWeight.w700));
  }
}

class _ComingSoonChip extends StatelessWidget{
  const _ComingSoonChip();
  @override
  Widget build(BuildContext context){
    final colorScheme=Theme.of(context).colorScheme;
    return Align(
      alignment:Alignment.centerLeft,
      child:Chip(avatar:Icon(Icons.sell_outlined,size:18,color:colorScheme.onSecondaryContainer),label:const Text('Coming soon'),backgroundColor:colorScheme.secondaryContainer,side:BorderSide.none),
    );
  }
}

class _NoteColorSelector extends StatelessWidget{
  const _NoteColorSelector({required this.selectedValue,required this.onSelected,required this.onCustomSelected});
  final int selectedValue;
  final ValueChanged<int> onSelected;
  final Future<void> Function() onCustomSelected;
  @override
  Widget build(BuildContext context){
    final customSelected=!isNotePresetColor(selectedValue);
    return Wrap(
      spacing:14,
      runSpacing:14,
      children:[
        for(final option in noteColorOptions)
          _ColorOption(
            option:option,
            customColor:option.isCustom&&customSelected?noteColorFromValue(selectedValue):null,
            selected:option.isCustom?customSelected:selectedValue==option.value,
            onTap:option.isCustom?()=>onCustomSelected():()=>onSelected(option.value),
          ),
      ],
    );
  }
}

class _ColorOption extends StatelessWidget{
  const _ColorOption({required this.option,required this.customColor,required this.selected,required this.onTap});
  final NoteColorOption option;
  final Color? customColor;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context){
    final color=option.isCustom?customColor:noteColorFromValue(option.value);
    final colorScheme=Theme.of(context).colorScheme;
    return Semantics(
      button:true,
      selected:selected,
      label:option.label,
      child:InkWell(
        onTap:onTap,
        borderRadius:BorderRadius.circular(18),
        child:AnimatedContainer(
          duration:const Duration(milliseconds:160),
          width:30,
          height:30,
          padding:const EdgeInsets.all(2),
          decoration:BoxDecoration(shape:BoxShape.circle,border:selected?Border.all(color:colorScheme.onSurface,width:2):null),
          child:DecoratedBox(
            decoration:BoxDecoration(
              color:color,
              gradient:option.isCustom&&color==null?const LinearGradient(colors:
                [Color(0xFFF17CFF),Color(0xFF6E8BFF),Color(0xFF6EE7B7),Color(0xFFFFD166)]):null,
              shape:BoxShape.circle,
            ),
            child:option.isCustom&&color==null?const Icon(Icons.colorize,size:14):null,
          ),
        ),
      ),
    );
  }
}

class _LastEditedLabel extends StatelessWidget{
  const _LastEditedLabel({this.date});
  final DateTime? date;
  @override
  Widget build(BuildContext context){
    final color=Theme.of(context).colorScheme.onSurfaceVariant;
    return Text(_label(),style:Theme.of(context).textTheme.bodySmall?.copyWith(color:color));
  }
  String _label(){
    if(date==null)return'Last edited just now';
    final elapsed=DateTime.now().difference(date!);
    if(elapsed.inMinutes<1)return'Last edited just now';
    if(elapsed.inHours<1)return'Last edited ${elapsed.inMinutes}m ago';
    if(elapsed.inDays<1)return'Last edited ${elapsed.inHours}h ago';
    if(elapsed.inDays<7)return'Last edited ${elapsed.inDays}d ago';
    return'Last edited ${date!.day}/${date!.month}/${date!.year}';
  }
}
