# Complete Implementation Guide: Part 3 (Summary)
## Farm Management System - Phases 4-9 Executive Summary

**This is the condensed action plan for the remaining phases. Refer to Parts 1-2 for detailed code.**

---

# Phase 4: Complete DDD Refactor
**Duration**: 3-4 weeks

## Checklist

### Domain Layer

- [ ] **Create Value Objects** (`lib/*/domain/value_objects/`)
  - Email, Password, PhoneNumber, Currency, Quantity
  - Each with validation in constructor
  - Immutable with Freezed

- [ ] **Define Aggregates**
  - Animal + AnimalWeight + AnimalHealth + ProductionLog
  - Crop + CropGrowthStage + HarvestRecord
  - Sale + SaleItem + Payment

- [ ] **Business Rules in Entities**
  - Move validation from UI to domain
  - Example: `Animal.canBreed()`, `Inventory.isLowStock()`

- [ ] **Domain Events**
  - `AnimalBred`, `CropHarvested`, `InventoryLowStock`
  - Use for cross-feature communication

### Application Layer

- [ ] **Create Use Cases** for each operation
  ```
  lib/farm_mgmt/application/usecases/
  ├── create_animal_usecase.dart
  ├── record_animal_weight_usecase.dart
  ├── schedule_feeding_usecase.dart
  └── ...
  ```

- [ ] **Use Case Pattern**:
  ```dart
  class CreateAnimalUseCase {
    final AnimalRepository _repository;
    
    Future<Either<Failure, Animal>> call(CreateAnimalParams params) async {
      // Validate
      // Business logic
      // Persist
    }
  }
  ```

### Infrastructure Layer

- [ ] **DTOs for API communication**
  ```dart
  @JsonSerializable()
  class AnimalDto {
    final int id;
    final String name;
    // ... fromJson, toJson, toDomain
  }
  ```

- [ ] **Repository Implementations**
  - Combine LocalData + ApiService
  - Handle offline/online logic
  - Return domain entities, not DTOs

---

# Phase 5: Backend Service Layer
**Duration**: 2 weeks

## Checklist

### Services

- [ ] **Create Service Classes**
  ```
  app/Services/
  ├── Farm/AnimalManagementService.php
  ├── Inventory/InventoryTrackingService.php
  ├── Sales/SalesAnalyticsService.php
  └── Notifications/NotificationService.php
  ```

- [ ] **Example Service**:
  ```php
  class AnimalManagementService
  {
      public function __construct(
          private AnimalRepository $animalRepo,
          private EventDispatcher $events,
      ) {}

      public function recordWeight(int $animalId, float $weight): void
      {
          $animal = $this->animalRepo->find($animalId);
          
          // Business logic
          if ($weight < $animal->previous_weight * 0.8) {
              $this->events->dispatch(new AnimalWeightDropped($animal));
          }
          
          // Persist
          $this->animalRepo->recordWeight($animalId, $weight);
      }
  }
  ```

### Form Requests

- [ ] **Create for each endpoint**
  ```
  app/Http/Requests/
  ├── StoreAnimalRequest.php
  ├── UpdateInventoryRequest.php
  └── ...
  ```

- [ ] **Example**:
  ```php
  class StoreAnimalRequest extends FormRequest
  {
      public function rules(): array
      {
          return [
              'name' => 'required|string|max:255',
              'type' => 'required|in:cattle,poultry,goat,sheep',
              'breed' => 'nullable|string|max:100',
              'birth_date' => 'nullable|date|before:today',
              'weight' => 'nullable|numeric|min:0',
          ];
      }

      public function messages(): array
      {
          return [
              'type.in' => 'Animal type must be cattle, poultry, goat, or sheep',
          ];
      }
  }
  ```

### API Resources

- [ ] **Create for responses**
  ```
  app/Http/Resources/
  ├── AnimalResource.php
  ├── InventoryResource.php
  └── ...
  ```

- [ ] **Example**:
  ```php
  class AnimalResource extends JsonResource
  {
      public function toArray($request): array
      {
          return [
              'id' => $this->id,
              'name' => $this->name,
              'type' => $this->type,
              'breed' => $this->breed,
              'age_months' => $this->age_in_months,
              'latest_weight' => new WeightResource($this->latestWeight),
              'health_status' => $this->health_status,
              'created_at' => $this->created_at->toISOString(),
          ];
      }
  }
  ```

### Update Controllers

- [ ] **Slim down controllers** to use services:
  ```php
  class AnimalController extends Controller
  {
      public function __construct(
          private AnimalManagementService $service
      ) {}

      public function store(StoreAnimalRequest $request)
      {
          $animal = $this->service->createAnimal(
              $request->validated()
          );

          return new AnimalResource($animal);
      }
  }
  ```

---

# Phase 6: Missing Features
**Duration**: 6-8 weeks

## Priority Order

### Week 1-2: Team Management & RBAC

**Backend**:
```php
// Database migration
Schema::create('roles', function (Blueprint $table) {
    $table->id();
    $table->string('name'); // owner, manager, worker
    $table->json('permissions');
    $table->timestamps();
});

Schema::create('user_roles', function (Blueprint $table) {
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->foreignId('role_id')->constrained()->onDelete('cascade');
    $table->foreignId('assigned_by')->nullable()->constrained('users');
});

// Middleware
class CheckPermission
{
    public function handle($request, Closure $next, string $permission)
    {
        if (!$request->user()->hasPermission($permission)) {
            abort(403, 'Unauthorized action');
        }
        return $next($request);
    }
}

// Usage
Route::delete('/animals/{id}', [...])
    ->middleware('permission:delete_animals');
```

**Flutter**:
- Create `TeamManagementScreen`
- Add role assignment UI
- Store user role in local state
- Hide features based on permissions

### Week 3-4: Financial Module

**Backend Models**:
```php
// Expense model
class Expense extends Model
{
    protected $fillable = [
        'user_id',
        'category',
        'amount',
        'description',
        'date',
        'receipt_path',
    ];
}

// Profit/Loss calculation service
class FinancialAnalyticsService
{
    public function getProfitLoss(User $user, Carbon $startDate, Carbon $endDate)
    {
        $revenue = Sale::where('user_id', $user->id)
            ->whereBetween('date', [$startDate, $endDate])
            ->sum('total_amount');

        $expenses = Expense::where('user_id', $user->id)
            ->whereBetween('date', [$startDate, $endDate])
            ->sum('amount');

        return [
            'revenue' => $revenue,
            'expenses' => $expenses,
            'profit' => $revenue - $expenses,
            'margin' => $revenue > 0 ? ($revenue - $expenses) / $revenue * 100 : 0,
        ];
    }
}
```

**Flutter**:
- Create `ExpenseScreen` with CRUD
- Create `FinancialDashboard` with charts
- Use `fl_chart` package for visualizations

### Week 5-6: Push Notifications

**Backend** (Firebase Cloud Messaging):
```bash
composer require kreait/firebase-php
```

```php
// Store FCM tokens
Schema::create('device_tokens', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained();
    $table->string('token')->unique();
    $table->string('device_type'); // ios, android
    $table->timestamps();
});

// Notification service
class PushNotificationService
{
    public function sendToUser(User $user, string $title, string $body, array $data = [])
    {
        $tokens = $user->deviceTokens()->pluck('token')->toArray();
        
        $message = CloudMessage::fromArray([
            'notification' => [
                'title' => $title,
                'body' => $body,
            ],
            'data' => $data,
        ]);

        foreach ($tokens as $token) {
            $this->messaging->send($message->withChangedTarget('token', $token));
        }
    }
}

// Usage
event(new InventoryLowStock($inventory));

// Listener
class NotifyLowStockListener
{
    public function handle(InventoryLowStock $event)
    {
        $this->notifications->sendToUser(
            $event->inventory->user,
            'Low Stock Alert',
            "{$event->inventory->item_name} is running low"
        );
    }
}
```

**Flutter**:
```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.10
  flutter_local_notifications: ^16.3.0
```

```dart
// lib/core/services/notification_service.dart
class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _fcm.requestPermission();
    
    final token = await _fcm.getToken();
    // Send token to backend
    await ApiService().post('/device-tokens', data: {'token': token});

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Show local notification
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification tap
      _handleNotificationTap(message);
    });
  }
}
```

### Week 7-8: Analytics Dashboard

**Backend**:
```php
class DashboardController extends Controller
{
    public function getKPIs(Request $request)
    {
        $user = $request->user();
        
        return response()->json([
            'total_animals' => $user->animals()->count(),
            'total_crops' => $user->crops()->count(),
            'low_stock_items' => Inventory::where('user_id', $user->id)
                ->whereColumn('quantity', '<=', 'min_stock')
                ->count(),
            'pending_tasks' => Task::where('user_id', $user->id)
                ->where('status', 'pending')
                ->count(),
            'monthly_revenue' => Sale::where('user_id', $user->id)
                ->whereMonth('date', now()->month)
                ->sum('total_amount'),
            'monthly_expenses' => Expense::where('user_id', $user->id)
                ->whereMonth('date', now()->month)
                ->sum('amount'),
        ]);
    }

    public function getSalesChart(Request $request)
    {
        $sales = Sale::where('user_id', $request->user()->id)
            ->whereBetween('date', [now()->subMonths(6), now()])
            ->selectRaw('DATE_FORMAT(date, "%Y-%m") as month, SUM(total_amount) as total')
            ->groupBy('month')
            ->get();

        return response()->json($sales);
    }
}
```

**Flutter**:
```dart
// Create dashboard with charts
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return state.when(
          loaded: (kpis, salesData) => Column(
            children: [
              // KPI Cards
              Row(
                children: [
                  KPICard(
                    title: 'Total Animals',
                    value: '${kpis.totalAnimals}',
                    icon: Icons.pets,
                  ),
                  KPICard(
                    title: 'Monthly Revenue',
                    value: '\$${kpis.monthlyRevenue}',
                    icon: Icons.attach_money,
                  ),
                ],
              ),
              
              // Sales Chart
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: salesData.map((data) =>
                          FlSpot(data.month, data.total)
                        ).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          loading: () => CircularProgressIndicator(),
          error: (msg) => Text('Error: $msg'),
        );
      },
    );
  }
}
```

---

# Phase 7: Performance Optimization
**Duration**: 2 weeks

## Backend Optimizations

### Database Indexing

```php
// Create migration: add_indexes_to_tables
Schema::table('inventories', function (Blueprint $table) {
    $table->index('user_id');
    $table->index(['user_id', 'category']);
    $table->index(['user_id', 'created_at']);
});

Schema::table('animals', function (Blueprint $table) {
    $table->index('user_id');
    $table->index(['user_id', 'type']);
});

Schema::table('sales', function (Blueprint $table) {
    $table->index('user_id');
    $table->index(['user_id', 'date']);
});
```

### Redis Caching

```php
// config/cache.php - ensure redis is default

// In controllers
public function index(Request $request)
{
    $inventories = Cache::remember(
        "inventory.user.{$request->user()->id}",
        3600, // 1 hour
        fn() => Inventory::where('user_id', $request->user()->id)->get()
    );

    return InventoryResource::collection($inventories);
}

// Clear cache on updates
public function store(StoreInventoryRequest $request)
{
    $inventory = Inventory::create($request->validated());
    
    Cache::forget("inventory.user.{$request->user()->id}");
    
    return new InventoryResource($inventory);
}
```

### Query Optimization

```php
// Before (N+1 queries)
$animals = Animal::all();
foreach ($animals as $animal) {
    echo $animal->latestWeight->weight; // N queries!
}

// After (2 queries)
$animals = Animal::with('latestWeight')->get();
```

### Pagination

```php
// In controllers
public function index(Request $request)
{
    $inventories = Inventory::where('user_id', $request->user()->id)
        ->paginate(20);

    return InventoryResource::collection($inventories);
}
```

## Flutter Optimizations

### List Virtualization

```dart
// Before
ListView(
  children: items.map((item) => ItemCard(item)).toList(),
)

// After
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemCard(items[index]),
)
```

### Image Caching

```yaml
dependencies:
  cached_network_image: ^3.3.1
```

```dart
CachedNetworkImage(
  imageUrl: item.imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### Debouncing Search

```dart
import 'package:rxdart/rxdart.dart';

final _searchController = StreamController<String>();

@override
void initState() {
  super.initState();
  
  _searchController.stream
      .debounceTime(const Duration(milliseconds: 500))
      .distinct()
      .listen((query) {
        context.read<InventoryBloc>().add(
          InventoryEvent.searchInventory(query: query),
        );
      });
}
```

### Const Constructors

```dart
// Use const wherever possible
const Text('Hello');
const Icon(Icons.home);
const SizedBox(height: 16);
```

---

# Phase 8: DevOps & Infrastructure
**Duration**: 3 weeks

## Docker Setup

**File**: `docker-compose.yml`

```yaml
version: '3.8'

services:
  app:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "8000:8000"
    environment:
      - DB_HOST=mysql
      - REDIS_HOST=redis
      - QUEUE_CONNECTION=redis
    volumes:
      - ./backend:/var/www/html
    depends_on:
      - mysql
      - redis

  mysql:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: pamoja_db
      MYSQL_ROOT_PASSWORD: secret
    volumes:
      - mysql-data:/var/lib/mysql
    ports:
      - "3306:3306"

  redis:
    image: redis:alpine
    ports:
      - "6379:6379"

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./backend/public:/var/www/html/public
    depends_on:
      - app

volumes:
  mysql-data:
```

**File**: `backend/Dockerfile`

```dockerfile
FROM php:8.2-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . .

# Install dependencies
RUN composer install --no-dev --optimize-autoloader

# Set permissions
RUN chown -R www-data:www-data /var/www/html

EXPOSE 8000

CMD php artisan serve --host=0.0.0.0 --port=8000
```

## CI/CD Pipeline

**File**: `.github/workflows/deploy.yml`

```yaml
name: Deploy to Production

on:
  push:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Laravel Tests
        run: |
          cd backend
          composer install
          php artisan test
      
      - name: Run Flutter Tests
        run: |
          flutter pub get
          flutter test

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Server
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          script: |
            cd /var/www/pamoja
            git pull origin main
            cd backend
            composer install --no-dev
            php artisan migrate --force
            php artisan config:cache
            php artisan route:cache
            sudo systemctl restart php8.2-fpm
```

## Monitoring Setup

### Laravel Telescope (Development)

```bash
composer require laravel/telescope --dev
php artisan telescope:install
php artisan migrate
```

### Sentry (Production)

```bash
composer require sentry/sentry-laravel
php artisan sentry:publish --dsn=your-dsn-here
```

```php
// config/logging.php
'channels' => [
    'stack' => [
        'driver' => 'stack',
        'channels' => ['single', 'sentry'],
    ],
    
    'sentry' => [
        'driver' => 'sentry',
    ],
],
```

**Flutter**:
```yaml
dependencies:
  sentry_flutter: ^7.14.0
```

```dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'your-dsn-here';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(PamojaApp()),
  );
}
```

## Backup Strategy

**File**: `backup.sh`

```bash
#!/bin/bash

# Database backup
DATE=$(date +%Y-%m-%d_%H-%M-%S)
mysqldump -u root -p$DB_PASSWORD pamoja_db | gzip > /backups/db_$DATE.sql.gz

# Upload to S3
aws s3 cp /backups/db_$DATE.sql.gz s3://pamoja-backups/db/

# Keep only last 30 days
find /backups -name "db_*.sql.gz" -mtime +30 -delete
```

**Cron**: `crontab -e`
```
0 2 * * * /usr/local/bin/backup.sh
```

---

# Phase 9: Production Deployment
**Duration**: 1-2 weeks

## Pre-Deployment Checklist

### Backend
- [ ] Set `APP_ENV=production`
- [ ] Set `APP_DEBUG=false`
- [ ] Generate new `APP_KEY`
- [ ] Configure CORS for production domain
- [ ] Enable SSL/TLS
- [ ] Set up queue workers
- [ ] Configure session driver (redis)
- [ ] Set up scheduled tasks (cron)
- [ ] Run `php artisan config:cache`
- [ ] Run `php artisan route:cache`
- [ ] Run `php artisan view:cache`

### Flutter
- [ ] Update API base URL for production
- [ ] Configure release signing keys
- [ ] Enable ProGuard/R8 (Android)
- [ ] Create App Store Connect listing (iOS)
- [ ] Create Play Store listing (Android)
- [ ] Test on real devices
- [ ] Run `flutter build apk --release`
- [ ] Run `flutter build ios --release`

## Server Setup (Ubuntu 22.04)

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Nginx
sudo apt install nginx -y

# Install PHP 8.2
sudo add-apt-repository ppa:ondrej/php
sudo apt update
sudo apt install php8.2-fpm php8.2-mysql php8.2-mbstring \
                 php8.2-xml php8.2-bcmath php8.2-curl -y

# Install MySQL
sudo apt install mysql-server -y
sudo mysql_secure_installation

# Install Redis
sudo apt install redis-server -y

# Install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Clone repository
cd /var/www
sudo git clone https://github.com/yourusername/pamoja.git
cd pamoja/backend

# Install dependencies
composer install --no-dev --optimize-autoloader

# Set permissions
sudo chown -R www-data:www-data /var/www/pamoja
sudo chmod -R 755 /var/www/pamoja

# Configure Nginx
sudo nano /etc/nginx/sites-available/pamoja

# Restart services
sudo systemctl restart nginx
sudo systemctl restart php8.2-fpm
```

**Nginx Config**:
```nginx
server {
    listen 80;
    server_name yourdomain.com;
    root /var/www/pamoja/backend/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

## Mobile App Release

### Android

1. **Create keystore**:
```bash
keytool -genkey -v -keystore ~/pamoja-key.jks -keyalg RSA \
        -keysize 2048 -validity 10000 -alias pamoja
```

2. **Configure signing** (`android/app/build.gradle`):
```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
```

3. **Build**:
```bash
flutter build appbundle --release
```

4. **Upload to Play Store Console**

### iOS

1. **Configure in Xcode**:
   - Open `ios/Runner.xcworkspace`
   - Set Bundle ID
   - Configure signing certificates
   - Set deployment target

2. **Build**:
```bash
flutter build ios --release
```

3. **Archive and upload via Xcode**

## Monitoring & Alerts

### Setup Uptime Robot
- Monitor `https://yourdomain.com/up`
- Send alerts to Slack/Email

### Setup Laravel Horizon Dashboard
```bash
php artisan horizon:install
```

Access at: `https://yourdomain.com/horizon`

### Setup New Relic / DataDog
- Install agent
- Configure API key
- Set up dashboards

---

# Summary: Complete Task List

## Phase 0: Setup ✅ (Already detailed in Part 1)
- Install dependencies
- Create folder structure
- Configure environment

## Phase 1: Security ✅ (Already detailed in Part 1)
- Implement rate limiting
- Strengthen passwords
- Add token refresh
- Input sanitization
- CORS configuration

## Phase 2: Testing ✅ (Already detailed in Part 1)
- Unit tests (Flutter & Laravel)
- Widget tests
- Integration tests
- Setup CI/CD

## Phase 3: BLoC Migration ✅ (Detailed in Part 2)
- Setup DI with GetIt
- Create Auth BLoC
- Migrate all screens to BLoC
- Remove Provider

## Phase 4: DDD Refactor (This Part)
- [ ] Create value objects
- [ ] Define aggregates
- [ ] Implement use cases
- [ ] Create DTOs
- [ ] Update repositories

## Phase 5: Backend Services (This Part)
- [ ] Create service layer
- [ ] Form requests
- [ ] API resources
- [ ] Update controllers

## Phase 6: Missing Features (This Part)
- [ ] Team management & RBAC
- [ ] Financial module
- [ ] Push notifications
- [ ] Analytics dashboard
- [ ] PDF export
- [ ] Payment integration

## Phase 7: Performance (This Part)
- [ ] Database indexes
- [ ] Redis caching
- [ ] Query optimization
- [ ] Pagination
- [ ] Image caching
- [ ] Debouncing

## Phase 8: DevOps (This Part)
- [ ] Docker setup
- [ ] CI/CD pipeline
- [ ] Monitoring (Sentry, Telescope)
- [ ] Backup automation

## Phase 9: Production (This Part)
- [ ] Server setup
- [ ] SSL certificates
- [ ] Mobile app release
- [ ] Final testing
- [ ] Launch! 🚀

---

# Next Steps for AI Agent

To execute this plan:

1. **Start with Phase 1** (Security) - Critical and impacts everything
2. **Then Phase 2** (Testing) - Enables safe refactoring
3. **Then Phase 3** (BLoC) - Core architecture
4. Work through phases 4-9 sequentially

Each file path and code block is ready to copy-paste. Good luck! 🌾
