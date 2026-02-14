# Complete Implementation Guide: Part 2
## Farm Management System - Phases 3-9

**Continuation from Part 1**

---

# Phase 3: BLoC Architecture Migration
**Duration**: 4-6 weeks  
**Priority**: HIGH

## Overview

We'll migrate from Provider to BLoC pattern feature by feature. Start with Auth, then move to other features.

## Task 3.1: Setup Dependency Injection

### Step 1: Create Service Locator

**File**: `lib/core/di/injection.dart` (create new)

```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() => getIt.init();
```

---

### Step 2: Create Injectable Config

**File**: `lib/core/di/injection.config.dart`

**Action**: This will be auto-generated, create placeholder:

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: flutter pub run build_runner build --delete-conflicting-outputs

import 'package:get_it/get_it.dart';

extension GetItInjectableX on GetIt {
  Future<void> init() async {
    // Auto-generated initialization will go here
  }
}
```

---

### Step 3: Register Dependencies

**File**: `lib/data/network/api_service.dart`

**Action**: Add `@lazySingleton` annotation:

```dart
import 'package:injectable/injectable.dart';

@lazySingleton
class ApiService {
  // ... existing code
}
```

---

**File**: `lib/core/network/token_manager.dart`

```dart
import 'package:injectable/injectable.dart';

@lazySingleton
class TokenManager {
  // ... existing code
}
```

---

**File**: `lib/data/services/auth_service.dart`

```dart
import 'package:injectable/injectable.dart';

@lazySingleton
class AuthService {
  final ApiService _api;
  final TokenManager _tokenManager;

  AuthService(this._api, this._tokenManager); // Constructor injection

  // ... rest of existing code
}
```

---

### Step 4: Update Main to Initialize DI

**File**: `lib/main.dart`

**Action**: Update `main()` function:

```dart
import 'core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load();

  // Initialize dependency injection
  configureDependencies();

  runApp(const PamojaApp());
}
```

---

## Task 3.2: Migrate Auth to BLoC

### Step 1: Create Auth Events

**File**: `lib/auth/presentation/bloc/auth_event.dart` (create new)

```dart
part of 'auth_bloc.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.loginRequested({
    required String email,
    required String password,
  }) = LoginRequested;

  const factory AuthEvent.registerRequested({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? farmName,
    String? location,
  }) = RegisterRequested;

  const factory AuthEvent.logoutRequested() = LogoutRequested;

  const factory AuthEvent.checkAuthStatus() = CheckAuthStatus;

  const factory AuthEvent.refreshTokenRequested() = RefreshTokenRequested;
}
```

---

### Step 2: Create Auth States

**File**: `lib/auth/presentation/bloc/auth_state.dart` (create new)

```dart
part of 'auth_bloc.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = Initial;
  
  const factory AuthState.loading() = Loading;
  
  const factory AuthState.authenticated({
    required User user,
  }) = Authenticated;
  
  const factory AuthState.unauthenticated() = Unauthenticated;
  
  const factory AuthState.error({
    required String message,
  }) = Error;
}
```

---

### Step 3: Create Auth BLoC

**File**: `lib/auth/presentation/bloc/auth_bloc.dart` (create new)

```dart
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../data/models/user.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/network/api_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final Logger _logger = Logger();

  AuthBloc(this._authService) : super(const AuthState.initial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<RefreshTokenRequested>(_onRefreshTokenRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      final user = await _authService.login(
        email: event.email,
        password: event.password,
      );

      emit(AuthState.authenticated(user: user));
      _logger.i('User logged in successfully: ${user.email}');
    } on ApiException catch (e) {
      _logger.e('Login failed', error: e);
      
      String message = 'Login failed';
      if (e.statusCode == 422) {
        message = 'Invalid email or password';
      } else if (e.statusCode == 429) {
        message = 'Too many login attempts. Please try again later.';
      }
      
      emit(AuthState.error(message: message));
    } catch (e) {
      _logger.e('Login failed', error: e);
      emit(const AuthState.error(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      final user = await _authService.register(
        name: event.name,
        email: event.email,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
        phone: event.phone,
        farmName: event.farmName,
        location: event.location,
      );

      emit(AuthState.authenticated(user: user));
      _logger.i('User registered successfully: ${user.email}');
    } on ApiException catch (e) {
      _logger.e('Registration failed', error: e);
      
      String message = 'Registration failed';
      if (e.statusCode == 422) {
        // Parse validation errors from response
        final errors = e.body['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          message = errors.values.first[0];
        }
      }
      
      emit(AuthState.error(message: message));
    } catch (e) {
      _logger.e('Registration failed', error: e);
      emit(const AuthState.error(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      await _authService.logout();
      emit(const AuthState.unauthenticated());
      _logger.i('User logged out successfully');
    } catch (e) {
      _logger.e('Logout failed', error: e);
      // Still emit unauthenticated even if API call fails
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      final isAuth = await TokenManager().isAuthenticated();
      
      if (isAuth) {
        final user = await _authService.getCurrentUser();
        emit(AuthState.authenticated(user: user));
      } else {
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      _logger.e('Auth check failed', error: e);
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onRefreshTokenRequested(
    RefreshTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Token refresh happens automatically in TokenManager
      // This event is mainly for triggering a refresh manually if needed
      final isAuth = await TokenManager().isAuthenticated();
      
      if (!isAuth) {
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      _logger.e('Token refresh failed', error: e);
      emit(const AuthState.unauthenticated());
    }
  }
}
```

---

### Step 4: Generate Freezed Code

**Command**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### Step 5: Update Login Screen to Use BLoC

**File**: `lib/auth/presentation/login_screen.dart`

**Action**: Replace entire file:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/auth_bloc.dart';
import '../../core/di/injection.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthEvent.loginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          state.when(
            initial: () {},
            loading: () {},
            authenticated: (user) {
              // Navigate to home
              Navigator.of(context).pushReplacementNamed('/home');
            },
            unauthenticated: () {},
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.red,
                ),
              );
            },
          );
        },
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Icon(
                      Icons.agriculture,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    
                    // Title
                    Text(
                      'Welcome Back',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    
                    Text(
                      'Login to manage your farm',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    
                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    
                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 24),
                    
                    // Login button
                    ElevatedButton(
                      onPressed: isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  Navigator.of(context)
                                      .pushReplacementNamed('/register');
                                },
                          child: const Text('Create account'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

---

### Step 6: Update Register Screen Similarly

**File**: `lib/auth/presentation/register_screen.dart`

**Action**: Follow same pattern as login screen:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/auth_bloc.dart';
import '../../core/di/injection.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: const RegisterView(),
    );
  }
}

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _locationController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _farmNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthEvent.registerRequested(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
          phone: _phoneController.text.trim().isNotEmpty 
              ? _phoneController.text.trim() 
              : null,
          farmName: _farmNameController.text.trim().isNotEmpty 
              ? _farmNameController.text.trim() 
              : null,
          location: _locationController.text.trim().isNotEmpty 
              ? _locationController.text.trim() 
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          state.when(
            initial: () {},
            loading: () {},
            authenticated: (user) {
              Navigator.of(context).pushReplacementNamed('/home');
            },
            unauthenticated: () {},
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.red,
                ),
              );
            },
          );
        },
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        helperText: 'Min 12 chars, uppercase, lowercase, number, symbol',
                        helperMaxLines: 2,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 12) {
                          return 'Password must be at least 12 characters';
                        }
                        if (!RegExp(r'[A-Z]').hasMatch(value)) {
                          return 'Password must contain uppercase letter';
                        }
                        if (!RegExp(r'[a-z]').hasMatch(value)) {
                          return 'Password must contain lowercase letter';
                        }
                        if (!RegExp(r'[0-9]').hasMatch(value)) {
                          return 'Password must contain a number';
                        }
                        if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                          return 'Password must contain a special character';
                        }
                        return null;
                      },
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Phone (optional)
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone (optional)',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Farm Name (optional)
                    TextFormField(
                      controller: _farmNameController,
                      decoration: InputDecoration(
                        labelText: 'Farm Name (optional)',
                        prefixIcon: const Icon(Icons.agriculture_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Location (optional)
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Location (optional)',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 24),

                    // Register button
                    ElevatedButton(
                      onPressed: isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  Navigator.of(context)
                                      .pushReplacementNamed('/login');
                                },
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

---

## Task 3.3: Create Inventory BLoC (Template for Other Features)

### Step 1: Create Inventory Events

**File**: `lib/inventory/presentation/bloc/inventory_event.dart` (create new)

```dart
part of 'inventory_bloc.dart';

@freezed
class InventoryEvent with _$InventoryEvent {
  const factory InventoryEvent.loadInventory() = LoadInventory;
  
  const factory InventoryEvent.addItem({
    required String itemName,
    required String category,
    required double quantity,
    required String unit,
    int? minStock,
    String? supplier,
    double? unitPrice,
    double? totalValue,
    String? notes,
    DateTime? lastRestock,
  }) = AddItem;

  const factory InventoryEvent.updateItem({
    required int id,
    String? itemName,
    String? category,
    double? quantity,
    String? unit,
    int? minStock,
    String? supplier,
    double? unitPrice,
    double? totalValue,
    String? notes,
    DateTime? lastRestock,
  }) = UpdateItem;

  const factory InventoryEvent.deleteItem({
    required int id,
  }) = DeleteItem;

  const factory InventoryEvent.searchInventory({
    required String query,
  }) = SearchInventory;

  const factory InventoryEvent.filterByCategory({
    required String category,
  }) = FilterByCategory;
}
```

---

### Step 2: Create Inventory States

**File**: `lib/inventory/presentation/bloc/inventory_state.dart` (create new)

```dart
part of 'inventory_bloc.dart';

@freezed
class InventoryState with _$InventoryState {
  const factory InventoryState.initial() = Initial;
  
  const factory InventoryState.loading() = Loading;
  
  const factory InventoryState.loaded({
    required List<InventoryItem> items,
    String? searchQuery,
    String? filterCategory,
  }) = Loaded;
  
  const factory InventoryState.error({
    required String message,
  }) = Error;
}
```

---

### Step 3: Create Inventory BLoC

**File**: `lib/inventory/presentation/bloc/inventory_bloc.dart` (create new)

```dart
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../data/models/inventory_dto.dart';
import '../../../data/services/inventory_service.dart';

part 'inventory_event.dart';
part 'inventory_state.dart';
part 'inventory_bloc.freezed.dart';

@injectable
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryService _inventoryService;
  final Logger _logger = Logger();

  List<InventoryItem> _allItems = [];

  InventoryBloc(this._inventoryService) : super(const InventoryState.initial()) {
    on<LoadInventory>(_onLoadInventory);
    on<AddItem>(_onAddItem);
    on<UpdateItem>(_onUpdateItem);
    on<DeleteItem>(_onDeleteItem);
    on<SearchInventory>(_onSearchInventory);
    on<FilterByCategory>(_onFilterByCategory);
  }

  Future<void> _onLoadInventory(
    LoadInventory event,
    Emitter<InventoryState> emit,
  ) async {
    emit(const InventoryState.loading());

    try {
      _allItems = await _inventoryService.getInventory();
      emit(InventoryState.loaded(items: _allItems));
      _logger.i('Inventory loaded: ${_allItems.length} items');
    } catch (e) {
      _logger.e('Failed to load inventory', error: e);
      emit(const InventoryState.error(message: 'Failed to load inventory'));
    }
  }

  Future<void> _onAddItem(
    AddItem event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await _inventoryService.addInventoryItem(
        itemName: event.itemName,
        category: event.category,
        quantity: event.quantity,
        unit: event.unit,
        minStock: event.minStock,
        supplier: event.supplier,
        unitPrice: event.unitPrice,
        totalValue: event.totalValue,
        notes: event.notes,
        lastRestock: event.lastRestock,
      );

      // Reload inventory
      add(const InventoryEvent.loadInventory());
      _logger.i('Inventory item added: ${event.itemName}');
    } catch (e) {
      _logger.e('Failed to add inventory item', error: e);
      emit(const InventoryState.error(message: 'Failed to add item'));
    }
  }

  Future<void> _onUpdateItem(
    UpdateItem event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await _inventoryService.updateInventoryItem(
        id: event.id,
        itemName: event.itemName,
        category: event.category,
        quantity: event.quantity,
        unit: event.unit,
        minStock: event.minStock,
        supplier: event.supplier,
        unitPrice: event.unitPrice,
        totalValue: event.totalValue,
        notes: event.notes,
        lastRestock: event.lastRestock,
      );

      // Reload inventory
      add(const InventoryEvent.loadInventory());
      _logger.i('Inventory item updated: ID ${event.id}');
    } catch (e) {
      _logger.e('Failed to update inventory item', error: e);
      emit(const InventoryState.error(message: 'Failed to update item'));
    }
  }

  Future<void> _onDeleteItem(
    DeleteItem event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await _inventoryService.deleteInventoryItem(event.id);

      // Reload inventory
      add(const InventoryEvent.loadInventory());
      _logger.i('Inventory item deleted: ID ${event.id}');
    } catch (e) {
      _logger.e('Failed to delete inventory item', error: e);
      emit(const InventoryState.error(message: 'Failed to delete item'));
    }
  }

  Future<void> _onSearchInventory(
    SearchInventory event,
    Emitter<InventoryState> emit,
  ) async {
    final query = event.query.toLowerCase();
    
    final filtered = _allItems.where((item) {
      return item.itemName.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query) ||
          (item.supplier?.toLowerCase().contains(query) ?? false);
    }).toList();

    emit(InventoryState.loaded(
      items: filtered,
      searchQuery: event.query,
    ));
  }

  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<InventoryState> emit,
  ) async {
    final filtered = _allItems.where((item) {
      return item.category == event.category;
    }).toList();

    emit(InventoryState.loaded(
      items: filtered,
      filterCategory: event.category,
    ));
  }
}
```

---

**Due to length constraints, I'll create a summary guide for the remaining phases (4-9) in a separate file:**

