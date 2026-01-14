class AppConstants {
  // App Info
  static const String appName = 'My Wallet';
  static const String appDescription = 'Manage your finances safely and easily';

  // Asset Paths
  static const String logoPath = 'assets/logo.png';
  static const String backgroundPath = 'assets/background.jpeg';

  // Hive Box Names
  static const String allocationPostBoxName = 'AllocationPostBox';

  // Allocation Percentages
  static const double housingPercentage = 0.25;
  static const double foodTransportPercentage = 0.15;
  static const double healthInsurancePercentage = 0.05;
  static const double otherExpensesPercentage = 0.05;
  static const double emergencyFundPercentage = 0.05;
  static const double longTermInvestmentPercentage = 0.15;
  static const double installmentsOutsideMortgages = 0.1;
  static const double creditCardInstalments = 0.05;
  static const double otherInstalments = 0.05;
  static const double healthFitness = 0.03;
  static const double skillsDevelopmentEducation = 0.04;
  static const double entertainmentSelfReward = 0.03;

  // Allocation Categories
  static const String categoryHousing = 'Housing and Utilities';
  static const String categoryFood = 'Food and Transport';
  static const String categoryHealth = 'Health Insurance';
  static const String categoryOther = 'Other Regular Expenses';
  static const String categoryEmergency = 'Emergency Fund';
  static const String categoryInvestment = 'Long-term Investment';
  static const String categoryInstallments =
      'Installments Outside of Mortgages';
  static const String categoryCreditCardInstalments = 'Card Instalments';
  static const String categoryOtherInstalments = 'Other Instalments';
  static const String categoryHealthFitness = 'Health and Fitness';
  static const String categorySkillsDevelopmentEducation =
      'Skills Development and Education';
  static const String categorySntertainmentSelfReward =
      'Entertainment and Self-Reward';

  // Navigation
  static const String loginRoute = '/login';

  // Error Messages
  static const String errorInitialization = 'Initialization error';
  static const String errorLogin =
      'Login failed or cancelled. Please try again.';
  static const String errorSHA1 =
      'The application configuration is incomplete. Please add the SHA-1 fingerprint in the Firebase Console.';
}
