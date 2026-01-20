class AppConstants {
  // App Info
  static const String appName = 'My Wallet';
  static const String appDescription =
      'Kelola keuangan Anda dengan aman dan mudah';

  // Asset Paths
  static const String logoPath = 'assets/logo.png';
  static const String backgroundPath = 'assets/background.jpeg';
  static const String backgroundCard = 'assets/card.jpg';

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
  static const String categoryHousing =
      'Kebutuhan Rumah (listrik, air, internet, dll)';
  static const String categoryFood = 'Makan & Transportasi';
  static const String categoryHealth = 'Asuransi Kesehatan';
  static const String categoryOther = 'Pengeluaran Rutin Lain';
  static const String categoryEmergency =
      'Dana Darurat (target terkumpul 6-12x pengeluaran bulanan)';
  static const String categoryInvestment =
      'Investasi Jangka Panjang (Pensiun, Kebebasan Finansial)';
  static const String categoryInstallments =
      'Angsuran Rumah dan atau Mobil';
  static const String categoryCreditCardInstalments =
      'Angsuran Kartu Kredit (jika ada)';
  static const String categoryOtherInstalments =
      'Angsuran Lain (Elektronik, dll)';
  static const String categoryHealthFitness = 'Kesehatan dan Olahraga';
  static const String categorySkillsDevelopmentEducation =
      'Pengembangan Skill & Pendidikan';
  static const String categorySntertainmentSelfReward =
      'Hiburan';

  // Navigation
  static const String loginRoute = '/login';

  // Error Messages
  static const String errorInitialization = 'Initialization error';
  static const String errorLogin =
      'Masuk gagal atau dibatalkan. Silakan coba lagi.';
  static const String errorSHA1 =
      'The application configuration is incomplete. Please add the SHA-1 fingerprint in the Firebase Console.';
}
