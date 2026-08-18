import 'package:example/models/user.dart';
import 'package:example/services/api_service.dart';
import 'package:example/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

class PasswordResetLinkWidget extends StatefulWidget {
  const PasswordResetLinkWidget({super.key});

  @override
  State<PasswordResetLinkWidget> createState() => _PasswordResetLinkWidgetState();
}

class _PasswordResetLinkWidgetState extends State<PasswordResetLinkWidget> {
  bool _isEmailSent = false;
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Метод для вызова API
  Future<bool> _sendPasswordResetEmail(String email) async {
    try {
      ApiService apiService = Provider.of<ApiService>(context, listen: false);
      final request = ClearRequest(
        email: email,
      );
      if (await apiService.clear(request)) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Произошла трагическая ошибка: $e');
      return false;
    }
  }

  void _showEmailDialog() {
    _emailController.clear();
    _formKey.currentState?.reset();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Сбросить пароль'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Почта',
                hintText: 'Введите ваш email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Поле email не может быть пустым';
                }
                // Опционально: проверка формата email
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                  return 'Введите корректный email';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              child: const Text('Отмена'),
              style: ElevatedButton.styleFrom(
                // backgroundColor: secondaryColor,
                foregroundColor: Colors.black,
              ),
            ),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _isLoading = true);

                        final email = _emailController.text.trim();
                        final success = await _sendPasswordResetEmail(email);

                        setState(() => _isLoading = false);

                        if (success) {
                          Navigator.pop(context);

                          // Обновляем состояние - показываем сообщение об отправке
                          setState(() {
                            _isEmailSent = true;
                          });
                        } else {
                          // Показываем ошибку
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ошибка при отправке. Попробуйте позже.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Подтвердить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isEmailSent
        ? const Text(
            'Новый пароль отправлен на почту',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          )
        : GestureDetector(
            onTap: _showEmailDialog,
            child: const Text(
              'Забыли пароль?',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
  }
}
