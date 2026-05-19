import 'package:example/providers/auth_provider.dart';
import 'package:example/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

final loginFormGlobalKey = GlobalKey<FormState>();

void showLoginDialog(BuildContext context) {
  // Получаем провайдер без подписки (только для передачи в диалог)
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  authProvider.clearError();

  // Локальные переменные для каждого экземпляра диалога
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => ChangeNotifierProvider.value(
      value: authProvider,
      child: AlertDialog(
        title: const Text('Авторизация'),
        content: Builder(
          builder: (_) {
            return Focus(
              autofocus: true,
              child: Container(
                padding: EdgeInsets.all(10),
                width: 400,
                child: Form(
                  key: formKey,
                  child: AutofillGroup(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: emailController,
                          autofillHints: const [AutofillHints.email],
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () {
                            authProvider.clearError();
                            FocusScope.of(context).nextFocus();
                          },
                          decoration: InputDecoration(
                            labelText: 'Почта',
                            hintText: 'user@mail.com',
                            filled: true,
                            fillColor: Colors.grey[200],
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[600]!, width: 1.5),
                              borderRadius: const BorderRadius.all(Radius.circular(4)),
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
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: passwordController,
                          autofillHints: const [AutofillHints.password],
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onEditingComplete: authProvider.isLoading
                              ? null
                              : () async {
                                  if (formKey.currentState?.validate() ?? false) {
                                    await authProvider.login(
                                      emailController.text.trim(),
                                      passwordController.text,
                                    );

                                    if (authProvider.error == null && authProvider.isAuth) {
                                      TextInput.finishAutofillContext();
                                      if (context.mounted) {
                                        Navigator.of(dialogContext).pop(true);
                                      }
                                    }
                                  }
                                },
                          decoration: InputDecoration(
                            labelText: 'Пароль',
                            filled: true,
                            fillColor: Colors.grey[200],
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[600]!, width: 1.5),
                              borderRadius: const BorderRadius.all(Radius.circular(4)),
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
                              return 'Укажите пароль';
                            }
                            if (value.length < 3) {
                              return 'Пароль не может быть меньше 3 символов';
                            }
                            return null;
                          },
                        ),
                        // Error
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            if (authProvider.error != null) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 20, bottom: 0),
                                child: Text(
                                  authProvider.error!,
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                            return const SizedBox(height: 20);
                          },
                        ),
                        // loader
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            return authProvider.isLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(),
                                  )
                                : const SizedBox(height: 0);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        actions: [
          Row(
            children: [
              SizedBox(width: 20),
              // cancel
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return Expanded(
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () {
                              authProvider.clearError();
                              Navigator.of(dialogContext).pop();
                            },
                      child: const Text('Отмена'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black54,
                        side: BorderSide(color: Colors.black12),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: 20),
              // login
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return Expanded(
                    child: ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () async {
                                if (formKey.currentState?.validate() ?? false) {
                                  await authProvider.login(
                                    emailController.text.trim(),
                                    passwordController.text,
                                  );

                                  if (authProvider.error == null && authProvider.isAuth) {
                                    TextInput.finishAutofillContext();
                                    if (context.mounted) {
                                      Navigator.of(dialogContext).pop(true);
                                    }
                                  }
                                }
                              },
                        child: const Text('Авторизоваться'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          foregroundColor: Colors.white,
                        )),
                  );
                },
              ),
              SizedBox(width: 20),
            ],
          )
        ],
      ),
    ),
  );

  authProvider.clearError();
}
