import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:note_pad/boxes/boxes.dart';
import '../constant/colors.dart';
import '../constant/text_style.dart';
import '../models/notes_model.dart';
import 'edit.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> filteredNotes = [];
  List<Note> sampleNotes = [];
  bool sorted = false;
//new
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _searchNote = [];
  final TextEditingController _headLineController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String noteDate = DateFormat("dd-MM-yyyy hh:mm aaa").format(DateTime.now());
  final _openBox = Hive.box('open_note');

  void _showEdit (BuildContext context, int? itemKey)async{
    if(itemKey != null){
      final existingItem = _items.firstWhere((element) => element['key'] == itemKey);
      _headLineController.text = existingItem['title'];
      _descriptionController.text = existingItem['content'];
    }

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea:true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15.0))),
        backgroundColor: Color(0xFFFFF8E1),
        builder: (context) => SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              bottom: MediaQuery.of(context).viewInsets.bottom,),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 30,left: 15,right: 15,bottom: 0),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          decoration:  BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              topLeft: Radius.circular(10),
                              bottomRight: Radius.circular(0),
                              bottomLeft: Radius.circular(0),
                            ),
                            color: Color(0xFFFFF3CD),
                          ),
                          padding: EdgeInsets.only(left: 10,right: 10,bottom: 5),

                          child: TextField(
                            controller: _headLineController,
                            style: getTextStyle(
                                19, FontWeight.normal,
                                tabBg),
                            decoration:  InputDecoration(
                              border: new UnderlineInputBorder(
                                borderSide: new BorderSide(
                                    color: Colors.red
                                ),),
                             // border: InputBorder.none,
                              hintText: ' Title',
                              hintStyle: getTextStyle2(
                                  19, FontWeight.normal,
                                  Colors.grey),
                          ),
                        ),),
                        //Divider(color: colorGrayLine),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration:  BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(0),
                                topLeft: Radius.circular(0),
                                bottomRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                              ),
                              color: Color(0xFFFFF3CD),
                            ),
                          child: TextField(
                            controller: _descriptionController,
                            style: getTextStyle(
                                16, FontWeight.normal,
                                colorBlack),
                           // keyboardType: TextInputType.multiline,
                            maxLines: 20,
                            decoration:  InputDecoration(
                              border: InputBorder.none,
                              hintText: ' Type something here',
                              hintStyle: getTextStyle2(
                                  16, FontWeight.normal,
                                  Colors.grey),),
                          ),
                        ),
                        //Divider(thickness: 1, color: colorGrayLine),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20,top: 20),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.purple,
                                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 5),
                                  textStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              onPressed: ()async{
                                if(_headLineController.text.isEmpty && _descriptionController.text.isEmpty){
                                  Fluttertoast.showToast(msg: 'Empty field!');
                                } else if (itemKey == null){
                                  createItem ({
                                    "title" : _headLineController.text,
                                    "content" : _descriptionController.text,
                                    "noteDate" : noteDate
                                  });
                                  Navigator.pop(context);
                                } else {
                                  editItem (itemKey,{
                                    "title" : _headLineController.text.trim(),
                                    "content" : _descriptionController.text.trim(),
                                    "noteDate" : noteDate.trim()
                                  });
                                  Navigator.pop(context);
                                }
                              },
                              child: const Icon(Icons.save),),
                          ),
                        ),
                        //Divider(thickness: 1, color: colorGrayLine),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )).whenComplete(() =>    setState(() {
      _headLineController.text = '';
      _descriptionController.text = '';
    }));
/*    showModalBottomSheet(context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15.0))),
        backgroundColor: Color(0xFFD7F9E9),
        isScrollControlled: true,
        builder: (_) =>
        Padding(
          padding:  EdgeInsets.only(top: 30),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color:Color(0xFFD7F9E9).withOpacity(.6), borderRadius: BorderRadius.circular(10)),
                padding:  EdgeInsets.only(left: 16,right: 16,top: 0,bottom: 20),
                child: Container(
                  padding:  EdgeInsets.only(bottom: 0),
                  height: MediaQuery.of(context).size.height / 1.6,
                  color: Colors.greenAccent,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: _headLineController,
                          style: getTextStyle(
                              20, FontWeight.normal,
                              colorBlack),
                          decoration:  InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Title',
                            hintStyle: getTextStyle2(
                                20, FontWeight.normal,
                                Colors.grey),),
                        ),
                        Divider(thickness: 1, color: colorGrayLine),
                        TextField(
                          controller: _descriptionController,
                          style: getTextStyle(
                              16, FontWeight.normal,
                              colorBlack),
                          keyboardType: TextInputType
                              .multiline,
                          maxLines: null,
                          decoration:  InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Type something here',
                            hintStyle: getTextStyle2(
                                16, FontWeight.normal,
                                Colors.grey),),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              ElevatedButton(onPressed: ()async{
                if(itemKey == null){
                  createItem ({
                    "title" : _headLineController.text,
                    "content" : _descriptionController.text
                  });
                }
                if(itemKey != null){
                  editItem (itemKey,{
                    "title" : _headLineController.text.trim(),
                    "content" : _descriptionController.text.trim()
                  });
                }


                Navigator.pop(context);
              }, child: const Icon(Icons.save),),
              SizedBox(height: 10,),
            ],
          ),
        )

    ).whenComplete(() =>    setState(() {
      _headLineController.text = '';
      _descriptionController.text = '';
    }));*/

  }

  Future<void> createItem (Map<String, dynamic> newItem)async{
    await _openBox.add(newItem);
    print('>>>>>>>>>>>${_openBox.length}');
    refreshItems ();

  }

  Future<void> editItem (int itemKey,Map<String, dynamic> item)async{
    await _openBox.put(itemKey, item);
    print('>>>>>>>>>>>${_openBox.length}');
    refreshItems ();

  }

  Future<void> deleteItem (int itemKey)async{
    await _openBox.delete(itemKey);
    print('>>>>>>>>>>>${_openBox.length}');
    refreshItems ();

  }

  void refreshItems () {
    final data = _openBox.keys.map((key){
      final item = _openBox.get(key);
      return {
        "key": key,
        "title": item["title"],
        "content": item["content"],
        "noteDate" : item["noteDate"]
      };

    } ).toList();
    setState(() {
      _items = data.reversed.toList();
      print('____________${_items.length}');
    });
  }

  @override
  void initState() {
    super.initState();
    refreshItems();
    filteredNotes = sampleNotes;
  }

  List<Note> sortNotesByModifiedTime(List<Note> notes) {
    if (sorted) {
      notes.sort((a, b) => a.modifiedTime.compareTo(b.modifiedTime));
    } else {
      notes.sort((b, a) => a.modifiedTime.compareTo(b.modifiedTime));
    }

    sorted = !sorted;

    return notes;
  }

  getRandomColor() {
    Random random = Random();
    return backgroundColors[random.nextInt(backgroundColors.length)];
  }

  void onSearchTextChanged(String searchText) {
    setState(() {
      filteredNotes = sampleNotes.where((note) =>
      note.content.toLowerCase().contains(searchText.toLowerCase()) ||
          note.title.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }

  void deleteNote(int index) {
    setState(() {
      Note note = filteredNotes[index];
      filteredNotes.removeAt(index);
      sampleNotes.remove(note);
    });
    //db.updateDataBase();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: colorAccentLightFade,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'NOTES',
                    style: TextStyle(fontSize: 30, color: Colors.black),
                  ),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          filteredNotes = sortNotesByModifiedTime(filteredNotes);
                        });
                      },
                      padding: const EdgeInsets.all(0),
                      icon: Container(
                        width: 40,
                        height: 30,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade800.withOpacity(.8),
                            borderRadius: BorderRadius.circular(5)),
                        child: const Icon(
                          Icons.sort,
                          color: Colors.white,
                        ),
                      ))
                ],
              ),
               SizedBox(
                height: 30,
              ),
             /* Container(
                padding: EdgeInsets.symmetric(horizontal: 17,vertical: 0),
                decoration: getBoxDecorations(
                    Color(0xFFD7F9E9), 5),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 18,
                      color: colorGrayDeep,),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 10),
                        decoration:  BoxDecoration(
                            color: Color(0xFFD7F9E9),
                            borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(5.0),
                              topRight: const Radius.circular(5.0),
                              bottomLeft: const Radius.circular(5.0),
                              bottomRight: const Radius.circular(5.0),
                            )
                        ),
                        child: TextField(
                            cursorHeight: 22,
                            obscureText: false,
                            onChanged: onSearchTextChanged,
                            style:  getTextStyle(
                                14, FontWeight.normal,
                                colorGrayDeep),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Search notes...",
                              hintStyle: getTextStyle(14,FontWeight.normal, colorGrayDeep),
                            ),
                        ),
                      ),
                    )
                  ],
                ),
              ),*/
              SizedBox(
                height: 10,
              ),
              /*Expanded(
                  child:ListView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 20),
                        color: getRandomColor(),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 5),
                          child: ListTile(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      EditScreen(note: filteredNotes[index]),
                                ),
                              );
                              if (result != null) {
                                setState(() {
                                  int originalIndex =
                                  sampleNotes.indexOf(filteredNotes[index]);

                                  sampleNotes[originalIndex] = Note(
                                      id: sampleNotes[originalIndex].id,
                                      title: result[0],
                                      content: result[1],
                                      modifiedTime: DateTime.now());

                                  filteredNotes[index] = Note(
                                      id: filteredNotes[index].id,
                                      title: result[0],
                                      content: result[1],
                                      modifiedTime: DateTime.now());
                                });
                              }
                            },

                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(filteredNotes[index].title,  style:getTextStyle(
                                    20, FontWeight.w500,
                                    colorBlack),),
                                Text('${filteredNotes[index].content}',
                                  style: getTextStyle(
                                      12, FontWeight.normal,
                                      Colors.black),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,),
                                Divider(thickness: 1, color: Color(0xffBCCCCCC)),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Text(
                                'Edited: ${DateFormat('EEE MMM d, yyyy h:mm a').format(filteredNotes[index].modifiedTime)}',
                                style: getTextStyle(
                                    10, FontWeight.normal,
                                    tabBg),
                              ),
                            ),
                            trailing: IconButton(
                              onPressed: () async {
                                final result = await confirmDialog(context);
                                if (result != null && result) {
                                  deleteNote(index);
                                }
                              },
                              icon: const Icon(
                                Icons.delete,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ))*/
              Expanded(
                  child:ListView.builder(
                    padding: const EdgeInsets.only(top: 5),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final currentItem = _items[index];
                      return _items.isEmpty ? Container(): Card(
                        margin: const EdgeInsets.only(bottom: 20),
                        color: getRandomColor(),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0,horizontal: 5),
                          child: ListTile(
                            onTap: () async{
                              _showEdit(context, currentItem['key']);
                            },
                      /*      onTap: () async {
                              _showEdit(context, currentItem["key"]);
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      EditScreen(note: filteredNotes[index]),
                                ),
                              );
                            },*/

                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(currentItem["title"],
                                  maxLines: 1,
                                  style:getTextStyle(
                                    20, FontWeight.w500,
                                    colorBlack),),
                                Text(currentItem["content"].toString(),
                                  style: getTextStyle(
                                      12, FontWeight.normal,
                                      Colors.black),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,),
                                Divider(thickness: 1, color: Color(0xffBCCCCCC)),
                                Text(
                                  'Edited: ${currentItem["noteDate"]}',
                                  style: getTextStyle(
                                      10, FontWeight.normal,
                                      tabBg),
                                ),
                              ],
                            ),

                            trailing: IconButton(
                              onPressed: () async {
                                final result = await confirmDialog(context);
                                if (result != null && result) {
                                  deleteItem(currentItem['key']);
                                  //deleteNote(index);
                                }
                              },
                              icon: const Icon(
                                Icons.delete,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ))
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            _showEdit(context, null);

          /*  final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const EditScreen(),
              ),
            );

            if (result != null) {
              setState(() {
                sampleNotes.add(Note(
                    id: sampleNotes.length,
                    title: result[0],
                    content: result[1],
                    modifiedTime: DateTime.now()));
                filteredNotes = sampleNotes;
              });
            }*/
          },
          elevation: 10,
          backgroundColor: Colors.grey.shade800,
          child: const Icon(
            Icons.add,
            size: 38,
          ),
        ),
      ),
    );
  }

  Future<dynamic> confirmDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFFE6F9FF),
            icon: const Icon(
              Icons.info,
              color: Colors.grey,
            ),
            title: const Text(
              'Are you sure you want to delete?',
              style: TextStyle(color: Colors.black),
            ),
            content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const SizedBox(
                        width: 60,
                        child: Text(
                          'Yes',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const SizedBox(
                        width: 60,
                        child: Text(
                          'No',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                ]),
          );
        });
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: capitalize(newValue.text),
      selection: newValue.selection,
    );
  }
}
String capitalize(String value) {
  if(value.trim().isEmpty) return "";
  return "${value[0].toUpperCase()}${value.substring(1).toLowerCase()}";
}