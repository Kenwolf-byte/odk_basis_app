import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:xml/xml.dart' as xml;
import 'package:csv/csv.dart';
import 'dart:convert';

class FormRenderer extends StatelessWidget {
  final String formType;
  final String formContent;

  const FormRenderer(
      {super.key, required this.formType, required this.formContent});

  @override
  Widget build(BuildContext context) {
    if (formType == 'xml') {
      return _renderXMLForm();
    } else if (formType == 'csv') {
      return _renderCSVForm();
    } else if (formType == 'xlsform') {
      return _renderXLSForm(); //=== You can implement XLSForm parsing here.
    } else if (formType == 'html') {
      return _renderHTMLForm();
    } else {
      return const Center(child: Text('Unknown or unsupported form type'));
    }
  }

  // Render XML Forms
  Widget _renderXMLForm() {
    final document = xml.parse(formContent);
    final questions =
        document.findAllElements('question'); //=== Example tag for questions
    return ListView.builder(
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final question = questions.elementAt(index);
        final questionText = question.findElements('label').first.text;
        return ListTile(
          title: Text(questionText),
          subtitle: TextField(onChanged: (text) {
            //=== Save to SQLite or elsewhere
          }),
        );
      },
    );
  }

  //=== Render CSV Forms
  Widget _renderCSVForm() {
    List<List<dynamic>> rows = const CsvToListConverter().convert(formContent);
    return ListView.builder(
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        return ListTile(
          title: Text(row[0]),
          subtitle: DropdownButton<String>(
            items: row.sublist(1).map<DropdownMenuItem<String>>((item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: (value) {
              //=== Handle selection based on choice or multiple choice questions
            },
          ),
        );
      },
    );
  }

  //=== Render HTML Forms (I used WebViewer here, You use any Html package of your choice and implememnt here)
  Widget _renderHTMLForm() {
    return WebView(
      initialUrl: Uri.dataFromString(formContent,
              mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
          .toString(),
      javascriptMode: JavascriptMode.unrestricted,
    );
  }

  //=== Placeholder for rendering XLSForm
  Widget _renderXLSForm() {
    return const Center(child: Text("XLSForm parsing is not implemented yet"));
  }
}
