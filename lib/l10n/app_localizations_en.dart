// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'My Budget Flow';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get joinUsTitle => 'Join Us Now!';

  @override
  String get joinUsSubtitle =>
      'Easily track your income and expenses, set your goals!';

  @override
  String get createAccountTitle => 'Create Account';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get resetPasswordDescription =>
      'Enter your email address and we will send you a link to reset your password.';

  @override
  String get emailLabel => 'Email Address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordConfirmLabel => 'Confirm Password';

  @override
  String get nameLabel => 'Name';

  @override
  String get surnameLabel => 'Surname';

  @override
  String get birthDateLabel => 'Birth Date';

  @override
  String get dateHint => 'DD.MM.YYYY';

  @override
  String get loginButton => 'Login';

  @override
  String get registerButton => 'Register';

  @override
  String get sendResetLinkButton => 'Send Reset Link';

  @override
  String get logoutButton => 'Logout';

  @override
  String get forgotPasswordQuestion => 'Forgot Password?';

  @override
  String get noAccountQuestion => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccountQuestion => 'Already have an account? Login';

  @override
  String get navHome => 'Home';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navGoals => 'Goals';

  @override
  String get pageTitleHome => 'Dashboard';

  @override
  String get pageTitleTransactions => 'Transactions';

  @override
  String get pageTitleCalendar => 'Calendar';

  @override
  String get pageTitleGoals => 'Goals';

  @override
  String get pageTitleProfile => 'Profile';

  @override
  String get pageTitleSettings => 'Settings';

  @override
  String get pageTitleNotifications => 'Notifications';

  @override
  String get pageTitleAbout => 'About';

  @override
  String get errorInvalidEmail => 'Please enter a valid email address.';

  @override
  String get errorEmptyField => 'This field cannot be empty.';

  @override
  String get errorPasswordShort => 'Must be at least 6 characters.';

  @override
  String get errorPasswordMismatch => 'Passwords do not match.';

  @override
  String get errorOnlyLetters => 'Please enter letters only.';

  @override
  String get errorLoginGeneral => 'An error occurred during login.';

  @override
  String get errorLoginWrongCredentials => 'Incorrect email or password.';

  @override
  String get errorRegisterEmailInUse => 'This email address is already in use.';

  @override
  String get errorRegisterGeneral => 'An error occurred during registration.';

  @override
  String get errorLoadingLanguageSettings =>
      'An error occurred while loading the language settings.';

  @override
  String get successRegister => 'Registration successful. Please login.';

  @override
  String get successResetEmailSent =>
      'A reset link has been sent to your email address.\nDon\'t forget to check your spam folder!';

  @override
  String get settingsLanguage => 'App Language';

  @override
  String get settingsLanguageTr => 'Turkish';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsTheme => 'App Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String errorGeneric(Object error) {
    return 'An error occurred: $error';
  }
}
