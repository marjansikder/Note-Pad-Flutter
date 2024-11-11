import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../constant/colors.dart';
import '../constant/text_style.dart';
import '../models/notes_model.dart';

class EditScreen extends StatefulWidget {
  final Note? note;
  const EditScreen({super.key, this.note});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  List<Note> sampleNotes = [];
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  DateTime date = DateTime.now();

  //new
  List<Map<String, dynamic>> items = [];
  final TextEditingController _headLineController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _openBox = Hive.box('open_note');

  Future<void> createItem(Map<String, dynamic> newItem) async {
    await _openBox.add(newItem);
    print('>>>>>>>>>>>${_openBox.length}');
    refreshItems();
  }

  void refreshItems() {
    final data = _openBox.keys.map((key) {
      final item = _openBox.get(key);
      return {
        "key": key,
        "headLine": item["headLine"],
        "content": item["content"],
      };
    }).toList();
    setState(() {
      items = data.reversed.toList();
      print('____________${items.length}');
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    if (widget.note != null) {
      _titleController = TextEditingController(text: widget.note!.title);
      _contentController = TextEditingController(text: widget.note!.content);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorGray,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
        child: SingleChildScrollView(
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    padding: const EdgeInsets.all(0),
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade800.withOpacity(.8),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                    )),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'EDIT',
                  style: TextStyle(fontSize: 30, color: Colors.black),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 30, bottom: 100),
              child: Container(
                //height: MediaQuery.of(context).size.height / 1.6,
                decoration: BoxDecoration(
                    //color:Color(0xFFD7F9E9).withOpacity(.6),
                    color: AppColors.colorAccentLightFade,
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      style:
                          getTextStyle(20, FontWeight.normal, AppColors.black),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Title',
                        hintStyle:
                            getTextStyle2(20, FontWeight.normal, Colors.grey),
                      ),
                    ),
                    Divider(thickness: 1, color: AppColors.colorGrayLine),
                    TextField(
                      controller: _contentController,
                      style:
                          getTextStyle(16, FontWeight.normal, AppColors.black),
                      maxLines: null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type something here',
                        hintStyle:
                            getTextStyle2(16, FontWeight.normal, Colors.grey),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
            )
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          createItem({
            "title": _headLineController.text,
            "content": _descriptionController.text
          });
          Navigator.pop(context);
        },
        elevation: 10,
        child: const Icon(Icons.save),
      ),
    );
  }
}
