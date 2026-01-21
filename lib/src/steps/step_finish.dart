import 'package:example/src/steps/steps.dart';
import 'package:example/src/widgets/text_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../register.dart';
import '../../providers/auth_provider.dart';
import 'my_wizard_step.dart';

class StepFinish extends StatefulWidgetStep {
  final StepFinishProvider myProvider;

  StepFinish({
    required StepFinishProvider provider,
    Key? key,
  })  : myProvider = provider,
        super(key: key, provider: provider);

  @override
  State<StepFinish> createState() => StepFinishState();
}

class StepFinishState extends StateStep<StepFinish> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  // get userCV => widget.provider.wizardController.pageController;

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
      List<Widget> textFields = [];
      if (authProvider.isAuth) {
        textFields = [TextBar('Вы зарегистрированы как ${authProvider.currentUser!.email}')];
      } else {
        textFields = [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Почта',
              hintText: 'user@mail.com',
              filled: true,
              fillColor: Colors.grey[200],
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[600]!, width: 1.5),
                borderRadius: const BorderRadius.all(
                  Radius.circular(4),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[800]!, width: 2.0),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Укажите почту';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Пароль',
              filled: true,
              fillColor: Colors.grey[200],
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[600]!, width: 1.5),
                borderRadius: const BorderRadius.all(
                  Radius.circular(4),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[800]!, width: 2.0),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Укажите пароль';
              }
              if (value.length < 3) {
                return 'Пароль не может быть меньше 3 символов';
              }
              return null;
            },
          ),
          // TextFormField(
          //   controller: _nameController,
          //   decoration: InputDecoration(labelText: 'Name'),
          // ),
          SizedBox(height: 20),
          if (authProvider.error != null)
            Text(
              authProvider.error!,
              style: TextStyle(color: Colors.red),
            ),
          SizedBox(height: 20),
          authProvider.isLoading ? CircularProgressIndicator() : SizedBox(height: 20),
        ];
      }

      return ListView(
        controller: _scrollController,
        children: [
          Form(
              key: _formKey,
              child: Column(
                children: textFields,
              ))
        ],
      );
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();

    _scrollController.dispose();
    super.dispose();
  }

  void onFinished() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final wizardProvider = Provider.of<ProviderExamplePageProvider>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      final userData = wizardProvider.cv!.data;
      final success = await authProvider.register(
        _emailController.text,
        _passwordController.text,
        userData,
      );

      if (success) {
        // @todo rebuild and hide registration form
        print('${authProvider.currentUser?.id} : ${authProvider.currentUser?.email}');
        Navigator.pushReplacementNamed(context, '/profile');
        // Navigator.pushNamed(context, '/profile');
      } else {
        print('Error register');
      }
    }
  }
}
