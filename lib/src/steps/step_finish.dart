import 'dart:js_interop';

import 'package:example/src/steps/steps.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/dropdown_field.dart';
import 'my_wizard_step.dart';

class StepSeven extends StatefulWidgetStep {
  final StepSevenProvider myProvider;

  StepSeven({
    required StepSevenProvider provider,
    Key? key,
  })  : myProvider = provider,
        super(key: key, provider: provider);

  @override
  State<StepSeven> createState() => _StepSevenState();
}

class _StepSevenState extends StateStep<StepSeven> {
  List<Map<String, String>> get achieveList => widget.myProvider.achieveList;
  int? _selectedAchieve;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final authProvider = Provider.of<AuthProvider>(context);

    return LayoutBuilder(builder: (context, constraints) {
      List<Widget> textFields = [
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(labelText: 'Email'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter email';
            }
            return null;
          },
        ),
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(labelText: 'Password'),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(labelText: 'Name'),
        ),
        SizedBox(height: 20),
        if (authProvider.error != null)
          Text(
            authProvider.error!,
            style: TextStyle(color: Colors.red),
          ),
        SizedBox(height: 20),
        authProvider.isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final userData = {
                      'name': _nameController.text,
                      'registration_type': 'web',
                    };

                    final success = await authProvider.register(
                      _emailController.text,
                      _passwordController.text,
                      userData,
                    );

                    if (success) {
                      // @todo rebuild and hide registration form
                      // Navigator.pushReplacementNamed(context, '/dashboard');
                    }
                  }
                },
                child: Text('Register'),
              ),
      ];

      return ListView(
        controller: _scrollController,
        children: textFields,
      );
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();

    // widget.provider.controllerByName('achieve_name').dispose();
    // widget.provider.controllerByName('achieve_skill').dispose();
    // widget.provider.controllerByName('achieve_result').dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
