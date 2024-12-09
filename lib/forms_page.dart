import 'package:flutter/material.dart';
import 'package:odk_basis_app/renderer/form_renderer.dart';
import 'package:odk_basis_app/services/odk_service.dart';

class FormsPage extends StatelessWidget {
  final String serverUrl;
  final String token;
  final int projectId;

  const FormsPage({
    super.key,
    required this.serverUrl,
    required this.token,
    required this.projectId,
  });

  Future<List> fetchForms() async {
    return await fetchFormsFromODK(serverUrl, token, projectId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forms')),
      body: FutureBuilder<List>(
        future: fetchForms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No forms found'));
          }

          final forms = snapshot.data!;
          return ListView.builder(
            itemCount: forms.length,
            itemBuilder: (context, index) {
              final form = forms[index];
              return ListTile(
                title: Text(form['name']),
                subtitle: Text('ID: ${form['id']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FormRenderer(
                        formType: form['type'],
                        formContent: form['content'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
