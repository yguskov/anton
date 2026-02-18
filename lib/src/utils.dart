import 'package:email_validator/email_validator.dart';

bool checkEmail(String email) {
  return EmailValidator.validate(email);
}
