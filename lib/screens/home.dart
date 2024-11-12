import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../constant/colors.dart';
import '../constant/text_style.dart';
import '../models/notes_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> filteredNotes = [];
  List<Note> sampleNotes = [];
  bool sorted = false;
  List<Map<String, dynamic>> _items = [];
  final TextEditingController _headLineController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String noteDate = DateFormat("dd-MM-yyyy hh:mm aaa").format(DateTime.now());
  final _openBox = Hive.box('open_note');

  void _showEdit(BuildContext context, int? itemKey) async {
    if (itemKey != null) {
      final existingItem =
          _items.firstWhere((element) => element['key'] == itemKey);
      _headLineController.text = existingItem['title'];
      _descriptionController.text = existingItem['content'];
    }

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15.0))),
        backgroundColor: Color(0xFFFFF8E1),
        builder: (context) => SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 0, left: 10, right: 10, bottom: 0),
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
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  topLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(0),
                                  bottomLeft: Radius.circular(0),
                                ),
                                color: Color(0xFFFFF3CD),
                              ),
                              padding: EdgeInsets.only(
                                  left: 10, right: 10, bottom: 5),
                              child: TextField(
                                controller: _headLineController,
                                style: getTextStyle(19, FontWeight.normal,
                                    AppColors.tabSelectedColor),
                                decoration: InputDecoration(
                                  border: new UnderlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.red),
                                  ),
                                  // border: InputBorder.none,
                                  hintText: ' Title',
                                  hintStyle: getTextStyle2(
                                      19, FontWeight.normal, Colors.grey),
                                ),
                              ),
                            ),
                            //Divider(color: colorGrayLine),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
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
                                    16, FontWeight.normal, AppColors.black),
                                // keyboardType: TextInputType.multiline,
                                maxLines: 20,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: ' Type something here',
                                  hintStyle: getTextStyle2(
                                      16, FontWeight.normal, Colors.grey),
                                ),
                              ),
                            ),
                            //Divider(thickness: 1, color: colorGrayLine),
                            Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 20, top: 20),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 100, vertical: 5),
                                      textStyle: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  onPressed: () async {
                                    if (_headLineController.text.isEmpty &&
                                        _descriptionController.text.isEmpty) {
                                      Fluttertoast.showToast(
                                          msg: 'Empty field!');
                                    } else if (itemKey == null) {
                                      createItem({
                                        "title": _headLineController.text,
                                        "content": _descriptionController.text,
                                        "noteDate": noteDate
                                      });
                                      Navigator.pop(context);
                                    } else {
                                      editItem(itemKey, {
                                        "title":
                                            _headLineController.text.trim(),
                                        "content":
                                            _descriptionController.text.trim(),
                                        "noteDate": noteDate.trim()
                                      });
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: const Icon(Icons.save,
                                      color: AppColors.white),
                                ),
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
            )).whenComplete(() => setState(() {
          _headLineController.text = '';
          _descriptionController.text = '';
        }));
  }

  Future<void> createItem(Map<String, dynamic> newItem) async {
    await _openBox.add(newItem);
    print('>>>>>>>>>>>${_openBox.length}');
    refreshItems();
  }

  Future<void> editItem(int itemKey, Map<String, dynamic> item) async {
    await _openBox.put(itemKey, item);
    print('>>>>>>>>>>>${_openBox.length}');
    refreshItems();
  }

  Future<void> deleteItem(int itemKey) async {
    await _openBox.delete(itemKey);
    print('>>>>>>>>>>>${_openBox.length}');
    refreshItems();
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
    return randomBackgroundColors[
        random.nextInt(randomBackgroundColors.length)];
  }

  void refreshItems() {
    final data = _openBox.keys.map((key) {
      final item = _openBox.get(key);
      return {
        "key": key,
        "title": item["title"],
        "content": item["content"],
        "noteDate": item["noteDate"]
      };
    }).toList();
    setState(() {
      _items = data.reversed.toList();
      print('____________${_items.length}');
    });
  }

  void onSearchTextChanged(String searchText) {
    setState(() {
      filteredNotes = sampleNotes
          .where((note) =>
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
  void initState() {
    super.initState();
    refreshItems();
    filteredNotes = sampleNotes;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NOTES : ${_items.length}',
                    style: TextStyle(fontSize: 30, color: Colors.black),
                  ),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          filteredNotes =
                              sortNotesByModifiedTime(filteredNotes);
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
              Expanded(
                  child: ListView.builder(
                padding: const EdgeInsets.only(top: 10, bottom: 80),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final currentItem = _items[index];
                  return _items.isEmpty
                      ? Center(
                          child: Text(
                            'Empty',
                            style: getTextStyle(
                                15, FontWeight.normal, AppColors.black),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            _showEdit(context, currentItem['key']);
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 20),
                            //color: getRandomColor(),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(5.0),
                                      bottomRight: Radius.circular(0.0),
                                      bottomLeft: Radius.circular(0.0),
                                      topLeft: Radius.circular(5.0),
                                    ),
                                    color: AppColors.colorPest,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          currentItem["title"],
                                          style: getTextStyle(
                                              15,
                                              FontWeight.normal,
                                              AppColors.ratingCountNumber),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          final result =
                                              await confirmDialog(context);
                                          if (result != null && result) {
                                            deleteItem(currentItem['key']);
                                            //deleteNote(index);
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: AppColors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height / 9,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(0.0),
                                      bottomRight: Radius.circular(0.0),
                                      bottomLeft: Radius.circular(0.0),
                                      topLeft: Radius.circular(0.0),
                                    ),
                                    //border: Border.all(color: AppColors.greenButton),
                                    color: getRandomColor(),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10.0,
                                        bottom: 5,
                                        left: 10,
                                        right: 10),
                                    child: Text(
                                        currentItem["content"].toString(),
                                        maxLines: 3,
                                        style: getTextStyle(
                                            13,
                                            FontWeight.normal,
                                            AppColors.black)),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(0.0),
                                      bottomRight: Radius.circular(5.0),
                                      bottomLeft: Radius.circular(5.0),
                                      topLeft: Radius.circular(0.0),
                                    ),
                                    color: Color(0xFFE6F9FF),
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Edited: ${currentItem["noteDate"]}',
                                      style: getTextStyle(10, FontWeight.normal,
                                          AppColors.tabSelectedColor),
                                    ),
                                  ),
                                ),
                              ],
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
          },
          elevation: 10,
          backgroundColor: AppColors.takaColor,
          child: const Icon(
            Icons.add,
            size: 38,
            color: AppColors.white,
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
              'Want to delete this?',
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
