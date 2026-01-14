# My Wallet - Personal Finance Management App

A Flutter-based personal finance management application that helps users track their income, allocate budgets, and manage transactions efficiently.

## Features

### 🔐 Authentication
- Firebase Authentication integration
- Google Sign-In support
- Secure user session management

### 💰 Income Management
- Set monthly income
- Date-based income tracking
- Income allocation calculator

### 📊 Budget Allocation (Based on 50/20/20/10 Rule)
- **Living Expenses & Obligations (50%)**
  - Housing & Utilities (25%)
  - Food & Transport (15%)
  - Health Insurance (5%)
  - Other Regular Expenses (5%)

- **Savings & Investment (20%)**
  - Emergency Fund (5%)
  - Long-term Investment (15%)

- **Installments & Commitments (20%)**
  - Outside of Mortgages (10%)
  - Credit Card Installments (5%)
  - Other Installments (5%)

- **Development & Lifestyle (10%)**
  - Health & Fitness (3%)
  - Skills & Education (4%)
  - Entertainment (3%)

### 💳 Transaction Management
- Record multiple transactions per category
- Real-time balance calculation
- Transaction validation against available allocation
- Auto-deduction from allocated budgets

### 📜 Transaction History
- View transactions by month and year
- Month picker with navigation
- Search and filter transactions
- Transaction details with category, date, and amount
- Empty state for no transactions

### 🏠 Dashboard
- Overview of wallet status
- Quick access to main features
- User profile information

## Tech Stack

- **Framework**: Flutter 3.10.4+
- **Language**: Dart
- **Database**: Hive (Local NoSQL Database)
- **Authentication**: Firebase Auth
- **State Management**: Provider
- **UI Components**: 
  - Curved Navigation Bar
  - Custom Bottom Navigation
  - Month Picker Bottom Sheet
  - Multi-currency formatter

## Dependencies

```yaml
firebase_core: ^3.15.2
firebase_auth: ^5.1.2
google_sign_in: ^6.1.0
hive: ^2.2.3
hive_flutter: ^1.1.0
flutter_secure_storage: ^10.0.0
path_provider: ^2.1.5
provider: ^6.1.5+1
intl: ^0.20.2
curved_navigation_bar: ^1.0.6
flutter_multi_formatter: ^2.13.10
```

## Project Structure

```
lib/
├── core/
│   ├── constants/        # App-wide constants
│   ├── theme/           # Theme and styling
│   └── utils/           # Utility functions
├── data/
│   ├── local/           # Hive database setup
│   └── models/          # Data models (Transaction, AllocationPost, MonthlyIncome)
├── presentation/
│   ├── screens/         # App screens
│   │   ├── dashboard_screen.dart
│   │   ├── wallet_screen.dart
│   │   ├── transaction_screen.dart
│   │   ├── history_trasaction_screen.dart
│   │   └── login_screen.dart
│   └── widgets/         # Reusable widgets
│       └── common/      # Common widgets
└── services/
    └── auth_service.dart # Authentication service
```

## Getting Started

### Prerequisites

- Flutter SDK (3.10.4 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase account

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd my_wallet
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Configure Firebase**
   - Add your `google-services.json` to `android/app/`
   - Add your `GoogleService-Info.plist` to `ios/Runner/`

5. **Run the app**
   ```bash
   flutter run
   ```

## Usage

1. **Login**: Sign in using Google authentication
2. **Set Income**: Navigate to Wallet screen and enter your monthly income
3. **Allocate Budget**: Use "Income Allocation" button to auto-calculate budget distribution
4. **Record Transactions**: Go to Transaction screen, select category, and add transaction items
5. **View History**: Check transaction history by month in History screen

## Data Models

### Transaction
- Email (user identifier)
- Date
- Category
- Item name
- Amount

### AllocationPost
- Email
- Category
- Amount
- Date

### MonthlyIncome
- Income amount
- Date

## Features in Development

- [ ] Analytics and reports
- [ ] Budget vs Actual comparison
- [ ] Export data to CSV/PDF
- [ ] Multi-currency support
- [ ] Recurring transactions
- [ ] Budget notifications

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is private and not licensed for public use.

## Support

For support, email [yulius.wijaya98@gmail.com] or create an issue in the repository.

---

**Note**: This is a personal finance management tool. Please ensure you backup your data regularly as it's stored locally on your device.
