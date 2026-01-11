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
  String get alreadyHaveAccountQuestion => 'Already have an account?';

  @override
  String get navHome => 'Home';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navGoals => 'Goals';

  @override
  String get pageTitleHome => 'My Budget Flow';

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
  String get profileUpdateSuccess => 'Profile updated successfully.';

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
  String get tabHistory => 'History';

  @override
  String get tabRecurring => 'Recurring';

  @override
  String get searchHint => 'Search...';

  @override
  String get filterTitle => 'Filter';

  @override
  String get clearAllFilters => 'Clear All';

  @override
  String get foundTransactionsPrefix => 'Found transactions: ';

  @override
  String get showResultsButton => 'Show Results';

  @override
  String get transactionTypeHeader => 'TRANSACTION TYPE';

  @override
  String get allTransactions => 'All';

  @override
  String get incomeType => 'Income';

  @override
  String get expenseType => 'Expense';

  @override
  String get dateHeader => 'DATE';

  @override
  String get dateToday => 'Today';

  @override
  String get dateWeek => 'This Week';

  @override
  String get dateMonth => 'This Month';

  @override
  String get date3Months => '3 Months';

  @override
  String get dateCustom => 'Custom Date';

  @override
  String get categoriesHeader => 'CATEGORIES';

  @override
  String get errorCategoriesLoad => 'Failed to load categories';

  @override
  String get addExpenseTitle => 'Add Expense';

  @override
  String get addIncomeTitle => 'Add Income';

  @override
  String get editTransactionTitle => 'Edit Transaction';

  @override
  String get addFromRecurring => 'Add from Recurring';

  @override
  String get errorEnterAmount => 'Please enter an amount';

  @override
  String get amountLabel => 'Amount';

  @override
  String get errorInvalidAmount => 'Invalid amount';

  @override
  String get titleHint => 'Title (e.g. Grocery Bill)';

  @override
  String get errorEnterTitle => 'Enter title';

  @override
  String get categoryLabel => 'Category';

  @override
  String get selectLabel => 'Select';

  @override
  String get dateLabel => 'Date';

  @override
  String get addNoteLabel => 'Add Note';

  @override
  String get noteHint => 'Write your note here...';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryBills => 'Bills';

  @override
  String get categoryTransport => 'Transportation';

  @override
  String get categoryRent => 'Rent';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categorySalary => 'Salary';

  @override
  String get categoryInvestment => 'Investment';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryOther => 'Other';

  @override
  String get saveButton => 'SAVE';

  @override
  String get makeRecurringLabel => 'Make Recurring';

  @override
  String get frequencyLabel => 'Frequency';

  @override
  String get selectCategoryTitle => 'Select Category';

  @override
  String get addNewCategoryTooltip => 'Add New Category';

  @override
  String get defaultCategoriesTitle => 'Default Categories';

  @override
  String get userCategoriesTitle => 'User Categories';

  @override
  String get deleteCategoryHint => 'Long press to delete';

  @override
  String errorMessagePrefix(Object error) {
    return 'Error: $error';
  }

  @override
  String get addNewCategoryTitle => 'Add New Category';

  @override
  String get categoryNameLabel => 'Category Name';

  @override
  String get selectColorLabel => 'Select Color';

  @override
  String get selectIconLabel => 'Select Icon';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get addButton => 'Add';

  @override
  String get deleteButton => 'Delete';

  @override
  String get undoAction => 'Undo';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get recurringDeleted => 'Recurring transaction deleted';

  @override
  String get noTransactionsFound => 'No transactions found.';

  @override
  String get addTransactionHint =>
      'You can add a new transaction using the \"+\" button.';

  @override
  String get addRecurringHint => 'You can add transactions like rent, bills.';

  @override
  String get deleteCategoryTitle => 'Delete Category?';

  @override
  String deleteCategoryConfirmMessage(Object category) {
    return 'Are you sure you want to delete \'$category\'?';
  }

  @override
  String get frequencyMonthly => 'Monthly';

  @override
  String get frequencyWeekly => 'Weekly';

  @override
  String get frequencyYearly => 'Yearly';

  @override
  String get frequencyDaily => 'Daily';

  @override
  String get recurringDescription =>
      'This transaction will be repeated at intervals.';

  @override
  String get selectRecurringTitle => 'Select Recurring Transaction';

  @override
  String get noRecurringFound => 'No recurring transactions found.';

  @override
  String get selectCategoryHint => 'Select a category';

  @override
  String get recurringSwitchLabel => 'Recurring Transaction';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get updateButton => 'UPDATE';

  @override
  String get noInternetTitle => 'No Internet Connection';

  @override
  String get noInternetMessage =>
      'Please check your internet connection and try again.';

  @override
  String get waitingConnection => 'Waiting for connection...';

  @override
  String errorAppInit(Object error) {
    return 'Application failed to initialize: $error';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get recurringActivated =>
      'Transaction activated and pending entries have been created.';

  @override
  String errorGeneric(Object error) {
    return 'An error occurred: $error';
  }

  @override
  String get dateRangeTitle => 'Date Range';

  @override
  String get dateSelectPlaceholder => 'Select';

  @override
  String get applySelectionButton => 'Apply Selection';

  @override
  String get shortDayMon => 'Mon';

  @override
  String get shortDayTue => 'Tue';

  @override
  String get shortDayWed => 'Wed';

  @override
  String get shortDayThu => 'Thu';

  @override
  String get shortDayFri => 'Fri';

  @override
  String get shortDaySat => 'Sat';

  @override
  String get shortDaySun => 'Sun';

  @override
  String get todayButtonTooltip => 'Today';

  @override
  String get netBalanceLabel => 'Total';

  @override
  String get plannedTransaction => 'Planned Transactions';

  @override
  String get thisMonthIncome => 'Monthly Income';

  @override
  String get thisMonthExpense => 'Monthly Expense';

  @override
  String get thisMonthNet => 'Monthly Net';

  @override
  String transactionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Transactions',
      one: '1 Transaction',
      zero: 'No Transactions',
    );
    return '$_temp0';
  }

  @override
  String get upcomingPaymentLabel => 'Upcoming Payment';

  @override
  String get recurringPaymentLabel => 'Recurring Payment';

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String get addRecurringTransactionTitle => 'Add Recurring Transaction';

  @override
  String dashboardWelcomeMessage(Object name) {
    return 'Welcome, $name';
  }

  @override
  String get dashboardNetStatus => 'Net Status';

  @override
  String get dashboardTotalIncome => 'Income';

  @override
  String get dashboardTotalExpense => 'Expense';

  @override
  String get dashboardInvestment => 'Investment';

  @override
  String get filterThisWeek => 'This Week';

  @override
  String get filterThisMonth => 'This Month';

  @override
  String get filterLast30Days => 'Last 30 Days';

  @override
  String get filterThisYear => 'This Year';

  @override
  String get chartSpendingDistribution => 'Spending Distribution';

  @override
  String get chartFinancialTrend => 'Financial Trend';

  @override
  String get goalsPlaceholder => 'Your goals will appear here.';

  @override
  String get goalAddTitle => 'Add New Goal';

  @override
  String get goalEditTitle => 'Edit Goal';

  @override
  String get goalTargetAmount => 'Target Amount';

  @override
  String get goalCurrentAmount => 'Current Savings';

  @override
  String get goalDeadline => 'Target Date';

  @override
  String get goalTitleLabel => 'Goal Title';

  @override
  String goalSavedAmount(Object amount) {
    return 'Saved: $amount';
  }

  @override
  String get addMoneyTitle => 'Add Money';

  @override
  String get withdrawMoneyTitle => 'Withdraw Money';

  @override
  String get goalDeleted => 'Goal deleted';

  @override
  String get aboutAppDescriptionTitle => 'About My Budget Flow';

  @override
  String get aboutAppDescription =>
      'A modern budget tracking app designed to simplify your personal finance management. Track your income and expenses, set goals, and save money.';

  @override
  String get aboutPrivacyTitle => 'Privacy and Security';

  @override
  String get aboutPrivacyContent =>
      'Your data is encrypted and stored securely on your device and our cloud servers. Your personal data is never shared with third parties.';
}
