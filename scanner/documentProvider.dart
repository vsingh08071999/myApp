import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:newapplication/bloc/authBloc.dart';
import 'package:newapplication/scanner/documentModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/widgets.dart' as pw;

class DocumentProvider extends ChangeNotifier {
  List<DocumentModel> allDocuments = [];
  Future<bool> getDocuments() async {
    allDocuments = [];
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print(sharedPreferences.getKeys());
    sharedPreferences.getKeys().forEach((key) {
      var jsonDocument = json.decode(sharedPreferences.getString(key));
      DocumentModel document = DocumentModel(
          name: jsonDocument['name'],
          documentPath: jsonDocument['documentPath'],
          dateTime: DateTime.parse(jsonDocument['dateTime']),
          pdfPath: jsonDocument['pdfPath'],
          shareLink: jsonDocument['shareLink']);
      allDocuments.add(document);
      print(document.documentPath);
    });
    allDocuments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    DocumentModel document = DocumentModel(
        name: "firstCard55466222",
        documentPath: "",
        dateTime: DateTime.utc(1969, 7, 20, 20, 18, 04),
        pdfPath: "",
        shareLink: "");
    allDocuments.add(document);
    notifyListeners();
    return true;
  }

  void saveDocument(
      {@required String name,
      @required String documentPath,
      @required DateTime dateTime,
      String shareLink,
      GlobalKey<AnimatedListState> animatedListKey,
      int angle}) async {
    final pdf = pw.Document();
    final image = PdfImage.file(
      pdf.document,
      bytes: File(documentPath).readAsBytesSync(),
    );
//    pdf.addPage(pw.Page(
//      pageFormat: PdfPageFormat(2480, 3508),
//      build: (pw.Context context) {
//        return pw.Image(image,
//            fit: angle == 0 || angle == 180
//                ? pw.BoxFit.fill
//                : pw.BoxFit.fitWidth);
//      },
//    ));
    final tempDir = await getTemporaryDirectory();
    String pdfPath = tempDir.path + "/${name}" + ".pdf";
    File pdfFile = File(pdfPath);
    print(pdfPath);
//    pdfFile.writeAsBytes(pdf.save());

    DocumentModel document = DocumentModel(
        name: name,
        documentPath: documentPath,
        dateTime: dateTime,
        pdfPath: pdfPath,
        shareLink: shareLink);

    String jsonDocument = json.encode({
      "name": document.name,
      "documentPath": document.documentPath,
      "dateTime": document.dateTime.toString(),
      "shareLink": document.shareLink,
      "pdfPath": document.pdfPath
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(
        document.dateTime.millisecondsSinceEpoch.toString(), jsonDocument);
    allDocuments.add(document);
    allDocuments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    Timer(Duration(milliseconds: 500), () {
      animatedListKey.currentState.insertItem(0);
    });
  }

  Future uploadFileToFirebase(context, String path) async {
    String photoUrl;

    final userid = context.bloc<AuthBloc>().state.userData.uid;
    String fileName = "scanner/$path";
    File file;
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(file);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          photoUrl = downloadUrl;
          Firestore.instance
              .collection('users')
              .document(userid)
              .updateData({'photoUrl': photoUrl}).then((data) {
            // await savelocalCode().toSaveStringValue(profile, photoUrl);
            Fluttertoast.showToast(msg: "Upload Successful");
            context.bloc<AuthBloc>().state.userData.profilePhoto = photoUrl;
            context.bloc<AuthBloc>().updateUser();
          }).catchError((err) {
            Fluttertoast.showToast(msg: err.toString());
            print("gggggggggggg${err.toString()}");
          });
        }, onError: (err) {
          Fluttertoast.showToast(msg: err.toString());
        });
      } else {
        Fluttertoast.showToast(msg: "This file is not an image");
      }
    }, onError: (err) {
      Fluttertoast.showToast(msg: err.toString());
      print("hhhhhhhh${err.toString()}");
    });
  }

  void deleteDocument(int index, String key) async {
    Timer(Duration(milliseconds: 300), () {
      allDocuments.removeAt(index);
      notifyListeners();
    });
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove(key);
  }

  void renameDocument(int index, String key, String changedName) async {
    allDocuments[index].name = changedName;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove(key);

    String jsonDocument = json.encode({
      "name": allDocuments[index].name,
      "documentPath": allDocuments[index].documentPath,
      "dateTime": allDocuments[index].dateTime.toString(),
      "shareLink": allDocuments[index].shareLink,
      "pdfPath": allDocuments[index].pdfPath
    });
    await sharedPreferences.setString(key, jsonDocument);
    Timer(Duration(milliseconds: 800), () {
      notifyListeners();
    });
  }
}
