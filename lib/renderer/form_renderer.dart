import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:xml/xml.dart' as xml;
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:excel/excel.dart';
import 'dart:typed_data';

class FormRenderer extends StatefulWidget {
  final String formType;
  final String formContent;

  const FormRenderer({
    super.key,
    required this.formType,
    required this.formContent,
  });

  @override
  FormRendererState createState() => FormRendererState();
}

class FormRendererState extends State<FormRenderer> {
  List<Map<String, dynamic>> rows = [];

  @override
  void initState() {
    super.initState();
    if (widget.formType == 'xlsform') {
      _loadXlsForm();
    }
  }

  //=== Render XML Forms
  Widget _renderXMLForm() {
    final document = xml.parse(widget.formContent);
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
    List<List<dynamic>> rows =
        const CsvToListConverter().convert(widget.formContent);
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
              //=== Handle selection based on choice or multiple-choice questions
            },
          ),
        );
      },
    );
  }

  //=== Render HTML Forms (WebView)
  Widget _renderHTMLForm() {
    return WebView(
      initialUrl: Uri.dataFromString(widget.formContent,
              mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
          .toString(),
      javascriptMode: JavascriptMode.unrestricted,
    );
  }

  //=== Render HTML Forms (WebView)
  Widget _renderXLSForm() {
    return rows.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, index) {
              var row = rows[index];
              return ListTile(
                title: Text(row['question'].toString()),
                subtitle: Text(row['options'].toString()),
                onTap: () {
                  //=== Handle user input here
                },
              );
            },
          );
  }

  //=== Render XLSForm (Using Excel package to parse XLS)
  Future<void> _loadXlsForm() async {
    final bytes = base64Decode(
        widget.formContent); //=== Assuming the content is base64-encoded
    var excel = Excel.decodeBytes(Uint8List.fromList(bytes));

    List<Map<String, dynamic>> parsedRows = [];
    for (var sheet in excel.tables.keys) {
      var table = excel.tables[sheet];
      if (table != null) {
        for (var row in table.rows) {
          parsedRows.add({
            'question': row[0] ??
                'No question', //=== Assuming the question is in the first column
            'options': row
                .sublist(1)
                .join(', ') //=== Assuming options are in the following columns
          });
        }
      }
    }

    setState(() {
      rows = parsedRows;
    });
  }

  //=== Display the form depending on the form type
  @override
  Widget build(BuildContext context) {
    if (widget.formType == 'xml') {
      return _renderXMLForm();
    } else if (widget.formType == 'csv') {
      return _renderCSVForm();
    } else if (widget.formType == 'xlsform') {
      return _renderXLSForm();
    } else if (widget.formType == 'html') {
      return _renderHTMLForm();
    } else {
      return const Center(child: Text('Unknown or unsupported form type'));
    }
  }
}
