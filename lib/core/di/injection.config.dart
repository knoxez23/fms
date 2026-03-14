// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../data/network/api_service.dart' as _i576;
import '../../data/repositories/sync_data.dart' as _i1004;
import '../../data/services/auth_service.dart' as _i117;
import '../../data/services/connectivity_service.dart' as _i761;
import '../../data/services/contact_directory_service.dart' as _i264;
import '../../data/services/crop_service.dart' as _i311;
import '../../data/services/inventory_service.dart' as _i374;
import '../../data/services/knowledge_service.dart' as _i97;
import '../../data/services/sale_service.dart' as _i970;
import '../../data/services/weather_service.dart' as _i791;
import '../../features/auth/application/auth_usecases.dart' as _i466;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/repositories/repositories.dart' as _i864;
import '../../features/auth/infrastructure/auth_repository_impl.dart' as _i420;
import '../../features/auth/presentation/bloc/auth/auth_bloc.dart' as _i469;
import '../../features/business/application/sales_usecases.dart' as _i149;
import '../../features/business/domain/repositories/sales_repository.dart'
    as _i415;
import '../../features/business/infrastructure/sales_repository_impl.dart'
    as _i379;
import '../../features/business/presentation/bloc/sales/sales_bloc.dart'
    as _i953;
import '../../features/farm_mgmt/application/animal_health_record_usecases.dart'
    as _i386;
import '../../features/farm_mgmt/application/animal_usecases.dart' as _i483;
import '../../features/farm_mgmt/application/breeding_usecases.dart' as _i320;
import '../../features/farm_mgmt/application/crop_usecases.dart' as _i993;
import '../../features/farm_mgmt/application/domain_event_subscribers.dart'
    as _i393;
import '../../features/farm_mgmt/application/feeding_usecases.dart' as _i516;
import '../../features/farm_mgmt/application/get_overview.dart' as _i329;
import '../../features/farm_mgmt/application/production_usecases.dart' as _i90;
import '../../features/farm_mgmt/application/task_usecases.dart' as _i712;
import '../../features/farm_mgmt/domain/repositories/animal_health_record_repository.dart'
    as _i1053;
import '../../features/farm_mgmt/domain/repositories/animal_repository.dart'
    as _i8;
import '../../features/farm_mgmt/domain/repositories/breeding_repository.dart'
    as _i156;
import '../../features/farm_mgmt/domain/repositories/crop_repository.dart'
    as _i377;
import '../../features/farm_mgmt/domain/repositories/feeding_repository.dart'
    as _i364;
import '../../features/farm_mgmt/domain/repositories/production_log_repository.dart'
    as _i350;
import '../../features/farm_mgmt/domain/repositories/repositories.dart'
    as _i491;
import '../../features/farm_mgmt/domain/repositories/task_repository.dart'
    as _i648;
import '../../features/farm_mgmt/infrastructure/animal_health_record_repository_impl.dart'
    as _i959;
import '../../features/farm_mgmt/infrastructure/animal_repository_impl.dart'
    as _i450;
import '../../features/farm_mgmt/infrastructure/breeding_repository_impl.dart'
    as _i661;
import '../../features/farm_mgmt/infrastructure/crop_repository_impl.dart'
    as _i240;
import '../../features/farm_mgmt/infrastructure/feeding_repository_impl.dart'
    as _i91;
import '../../features/farm_mgmt/infrastructure/production_log_repository_impl.dart'
    as _i761;
import '../../features/farm_mgmt/infrastructure/task_repository_impl.dart'
    as _i863;
import '../../features/farm_mgmt/presentation/bloc/animals/animals_bloc.dart'
    as _i734;
import '../../features/farm_mgmt/presentation/bloc/breeding/breeding_cubit.dart'
    as _i1050;
import '../../features/farm_mgmt/presentation/bloc/crops/crops_bloc.dart'
    as _i141;
import '../../features/farm_mgmt/presentation/bloc/feeding/feeding_bloc.dart'
    as _i947;
import '../../features/farm_mgmt/presentation/bloc/navigation/farm_nav_cubit.dart'
    as _i719;
import '../../features/farm_mgmt/presentation/bloc/overview/overview_bloc.dart'
    as _i16;
import '../../features/farm_mgmt/presentation/bloc/production/production_log_cubit.dart'
    as _i345;
import '../../features/farm_mgmt/presentation/bloc/tasks/tasks_bloc.dart'
    as _i328;
import '../../features/home/application/get_dashboard_data.dart' as _i156;
import '../../features/home/presentation/bloc/home/home_bloc.dart' as _i495;
import '../../features/inventory/application/inventory_usecases.dart' as _i8;
import '../../features/inventory/domain/repositories/inventory_repository.dart'
    as _i422;
import '../../features/inventory/domain/repositories/repositories.dart'
    as _i507;
import '../../features/inventory/infrastructure/inventory_repository_impl.dart'
    as _i642;
import '../../features/inventory/presentation/bloc/inventory/inventory_bloc.dart'
    as _i1046;
import '../../features/knowledge/application/knowledge_usecases.dart' as _i734;
import '../../features/knowledge/domain/repositories/knowledge_repository.dart'
    as _i1010;
import '../../features/knowledge/infrastructure/knowledge_repository_impl.dart'
    as _i490;
import '../../features/knowledge/presentation/bloc/knowledge/knowledge_cubit.dart'
    as _i263;
import '../../features/marketplace/application/marketplace_usecases.dart'
    as _i496;
import '../../features/marketplace/domain/repositories/marketplace_repository.dart'
    as _i633;
import '../../features/marketplace/domain/repositories/repositories.dart'
    as _i828;
import '../../features/marketplace/infrastructure/marketplace_repository_impl.dart'
    as _i676;
import '../../features/marketplace/presentation/bloc/marketplace/marketplace_bloc.dart'
    as _i60;
import '../../features/onboarding/presentation/bloc/onboarding/onboarding_cubit.dart'
    as _i539;
import '../../features/profile/application/profile_usecases.dart' as _i781;
import '../../features/profile/domain/repositories/profile_repository.dart'
    as _i894;
import '../../features/profile/domain/repositories/repositories.dart' as _i91;
import '../../features/profile/infrastructure/profile_repository_impl.dart'
    as _i603;
import '../../features/profile/presentation/bloc/profile/audit_events_cubit.dart'
    as _i224;
import '../../features/profile/presentation/bloc/profile/profile_bloc.dart'
    as _i717;
import '../../features/weather/application/weather_usecases.dart' as _i739;
import '../../features/weather/domain/repositories/weather_repository.dart'
    as _i956;
import '../../features/weather/infrastructure/weather_repository_impl.dart'
    as _i346;
import '../../features/weather/presentation/bloc/weather/weather_cubit.dart'
    as _i400;
import '../domain/events/domain_event_bus.dart' as _i468;
import '../domain/repositories/farm_summary_repository.dart' as _i873;
import '../events/domain_event_bus.dart' as _i73;
import '../infrastructure/farm_summary_repository_impl.dart' as _i3;
import '../network/api_service.dart' as _i921;
import '../network/token_manager.dart' as _i374;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i719.FarmNavCubit>(() => _i719.FarmNavCubit());
    gh.factory<_i539.OnboardingCubit>(() => _i539.OnboardingCubit());
    gh.lazySingleton<_i921.ApiService>(() => _i921.ApiService());
    gh.lazySingleton<_i374.TokenManager>(() => _i374.TokenManager());
    gh.lazySingleton<_i73.DomainEventBus>(
      () => _i73.DomainEventBus(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i468.DomainEventBus>(
      () => _i468.DomainEventBus(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i1004.SyncData>(() => _i1004.SyncData());
    gh.lazySingleton<_i761.ConnectivityService>(
        () => _i761.ConnectivityService());
    gh.lazySingleton<_i311.CropService>(() => _i311.CropService());
    gh.lazySingleton<_i970.SaleService>(() => _i970.SaleService());
    gh.lazySingleton<_i576.ApiService>(() => _i576.ApiService());
    gh.lazySingleton<_i648.TaskRepository>(
        () => _i863.TaskRepositoryImpl(gh<_i1004.SyncData>()));
    gh.lazySingleton<_i350.ProductionLogRepository>(
        () => _i761.ProductionLogRepositoryImpl());
    gh.lazySingleton<_i873.FarmSummaryRepository>(
        () => _i3.FarmSummaryRepositoryImpl(gh<_i1004.SyncData>()));
    gh.lazySingleton<_i364.FeedingRepository>(
        () => _i91.FeedingRepositoryImpl(gh<_i1004.SyncData>()));
    gh.lazySingleton<_i329.GetOverview>(
        () => _i329.GetOverview(gh<_i873.FarmSummaryRepository>()));
    gh.lazySingleton<_i377.CropRepository>(
        () => _i240.CropRepositoryImpl(gh<_i1004.SyncData>()));
    gh.factory<_i16.OverviewBloc>(
        () => _i16.OverviewBloc(gh<_i329.GetOverview>()));
    gh.lazySingleton<_i1053.AnimalHealthRecordRepository>(
        () => _i959.AnimalHealthRecordRepositoryImpl(gh<_i1004.SyncData>()));
    gh.lazySingleton<_i386.GetAnimalHealthRecords>(() =>
        _i386.GetAnimalHealthRecords(
            gh<_i1053.AnimalHealthRecordRepository>()));
    gh.lazySingleton<_i386.AddAnimalHealthRecord>(() =>
        _i386.AddAnimalHealthRecord(gh<_i1053.AnimalHealthRecordRepository>()));
    gh.lazySingleton<_i386.UpdateAnimalHealthRecord>(() =>
        _i386.UpdateAnimalHealthRecord(
            gh<_i1053.AnimalHealthRecordRepository>()));
    gh.lazySingleton<_i386.DeleteAnimalHealthRecord>(() =>
        _i386.DeleteAnimalHealthRecord(
            gh<_i1053.AnimalHealthRecordRepository>()));
    gh.lazySingleton<_i156.BreedingRepository>(
        () => _i661.BreedingRepositoryImpl());
    gh.lazySingleton<_i633.MarketplaceRepository>(
        () => _i676.MarketplaceRepositoryImpl());
    gh.lazySingleton<_i993.GetCrops>(
        () => _i993.GetCrops(gh<_i491.CropRepository>()));
    gh.lazySingleton<_i993.DeleteCrop>(
        () => _i993.DeleteCrop(gh<_i491.CropRepository>()));
    gh.lazySingleton<_i374.InventoryService>(
        () => _i374.InventoryService(gh<_i576.ApiService>()));
    gh.lazySingleton<_i97.KnowledgeService>(
        () => _i97.KnowledgeService(gh<_i576.ApiService>()));
    gh.lazySingleton<_i791.WeatherService>(
        () => _i791.WeatherService(gh<_i576.ApiService>()));
    gh.lazySingleton<_i264.ContactDirectoryService>(
        () => _i264.ContactDirectoryService(gh<_i576.ApiService>()));
    gh.lazySingleton<_i8.AnimalRepository>(
        () => _i450.AnimalRepositoryImpl(gh<_i1004.SyncData>()));
    gh.lazySingleton<_i320.AddBreedingRecord>(() => _i320.AddBreedingRecord(
          gh<_i156.BreedingRepository>(),
          gh<_i468.DomainEventBus>(),
        ));
    gh.lazySingleton<_i993.AddCrop>(() => _i993.AddCrop(
          gh<_i491.CropRepository>(),
          gh<_i468.DomainEventBus>(),
        ));
    gh.lazySingleton<_i993.UpdateCrop>(() => _i993.UpdateCrop(
          gh<_i491.CropRepository>(),
          gh<_i468.DomainEventBus>(),
        ));
    gh.lazySingleton<_i393.DomainEventSubscribers>(
      () => _i393.DomainEventSubscribers(
        gh<_i468.DomainEventBus>(),
        gh<_i648.TaskRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i117.AuthService>(() => _i117.AuthService(
          gh<_i576.ApiService>(),
          gh<_i374.TokenManager>(),
        ));
    gh.factory<_i141.CropsBloc>(() => _i141.CropsBloc(
          gh<_i993.GetCrops>(),
          gh<_i993.AddCrop>(),
          gh<_i993.UpdateCrop>(),
          gh<_i993.DeleteCrop>(),
        ));
    gh.lazySingleton<_i516.GetFeedingSchedules>(
        () => _i516.GetFeedingSchedules(gh<_i364.FeedingRepository>()));
    gh.lazySingleton<_i516.GetFeedingLogs>(
        () => _i516.GetFeedingLogs(gh<_i364.FeedingRepository>()));
    gh.lazySingleton<_i516.AddFeedingSchedule>(
        () => _i516.AddFeedingSchedule(gh<_i364.FeedingRepository>()));
    gh.lazySingleton<_i516.UpdateFeedingSchedule>(
        () => _i516.UpdateFeedingSchedule(gh<_i364.FeedingRepository>()));
    gh.lazySingleton<_i516.DeleteFeedingSchedule>(
        () => _i516.DeleteFeedingSchedule(gh<_i364.FeedingRepository>()));
    gh.lazySingleton<_i516.AddFeedingLog>(
        () => _i516.AddFeedingLog(gh<_i364.FeedingRepository>()));
    gh.lazySingleton<_i516.UpdateFeedingLog>(
        () => _i516.UpdateFeedingLog(gh<_i364.FeedingRepository>()));
    gh.lazySingleton<_i516.DeleteFeedingLog>(
        () => _i516.DeleteFeedingLog(gh<_i364.FeedingRepository>()));
    gh.lazySingleton<_i496.GetProducts>(
        () => _i496.GetProducts(gh<_i828.MarketplaceRepository>()));
    gh.lazySingleton<_i496.AddProduct>(
        () => _i496.AddProduct(gh<_i828.MarketplaceRepository>()));
    gh.lazySingleton<_i496.UpdateProduct>(
        () => _i496.UpdateProduct(gh<_i828.MarketplaceRepository>()));
    gh.lazySingleton<_i496.DeleteProduct>(
        () => _i496.DeleteProduct(gh<_i828.MarketplaceRepository>()));
    gh.lazySingleton<_i496.SubmitMarketplaceInquiry>(() =>
        _i496.SubmitMarketplaceInquiry(gh<_i828.MarketplaceRepository>()));
    gh.lazySingleton<_i712.GetTasks>(
        () => _i712.GetTasks(gh<_i491.TaskRepository>()));
    gh.lazySingleton<_i712.AddTask>(
        () => _i712.AddTask(gh<_i491.TaskRepository>()));
    gh.lazySingleton<_i712.DeleteTask>(
        () => _i712.DeleteTask(gh<_i491.TaskRepository>()));
    gh.lazySingleton<_i483.GetAnimals>(
        () => _i483.GetAnimals(gh<_i491.AnimalRepository>()));
    gh.lazySingleton<_i483.AddAnimal>(
        () => _i483.AddAnimal(gh<_i491.AnimalRepository>()));
    gh.lazySingleton<_i483.UpdateAnimal>(
        () => _i483.UpdateAnimal(gh<_i491.AnimalRepository>()));
    gh.lazySingleton<_i483.DeleteAnimal>(
        () => _i483.DeleteAnimal(gh<_i491.AnimalRepository>()));
    gh.lazySingleton<_i90.GetProductionLogs>(
        () => _i90.GetProductionLogs(gh<_i350.ProductionLogRepository>()));
    gh.lazySingleton<_i90.AddProductionLog>(
        () => _i90.AddProductionLog(gh<_i350.ProductionLogRepository>()));
    gh.lazySingleton<_i90.DeleteProductionLog>(
        () => _i90.DeleteProductionLog(gh<_i350.ProductionLogRepository>()));
    gh.lazySingleton<_i320.GetBreedingRecords>(
        () => _i320.GetBreedingRecords(gh<_i156.BreedingRepository>()));
    gh.lazySingleton<_i320.DeleteBreedingRecord>(
        () => _i320.DeleteBreedingRecord(gh<_i156.BreedingRepository>()));
    gh.factory<_i947.FeedingBloc>(() => _i947.FeedingBloc(
          gh<_i516.GetFeedingSchedules>(),
          gh<_i516.GetFeedingLogs>(),
          gh<_i483.GetAnimals>(),
          gh<_i516.UpdateFeedingSchedule>(),
          gh<_i516.AddFeedingLog>(),
          gh<_i516.DeleteFeedingLog>(),
        ));
    gh.lazySingleton<_i956.WeatherRepository>(
        () => _i346.WeatherRepositoryImpl(gh<_i791.WeatherService>()));
    gh.lazySingleton<_i712.UpdateTask>(() => _i712.UpdateTask(
          gh<_i491.TaskRepository>(),
          gh<_i468.DomainEventBus>(),
        ));
    gh.lazySingleton<_i787.AuthRepository>(() => _i420.AuthRepositoryImpl(
          gh<_i117.AuthService>(),
          gh<_i374.TokenManager>(),
        ));
    gh.lazySingleton<_i466.SignIn>(
        () => _i466.SignIn(gh<_i864.AuthRepository>()));
    gh.lazySingleton<_i466.Register>(
        () => _i466.Register(gh<_i864.AuthRepository>()));
    gh.lazySingleton<_i466.SignOut>(
        () => _i466.SignOut(gh<_i864.AuthRepository>()));
    gh.lazySingleton<_i466.GetCurrentUser>(
        () => _i466.GetCurrentUser(gh<_i864.AuthRepository>()));
    gh.lazySingleton<_i466.CheckAuthStatusUseCase>(
        () => _i466.CheckAuthStatusUseCase(gh<_i864.AuthRepository>()));
    gh.factory<_i328.TasksBloc>(() => _i328.TasksBloc(
          gh<_i712.GetTasks>(),
          gh<_i712.AddTask>(),
          gh<_i712.UpdateTask>(),
          gh<_i712.DeleteTask>(),
        ));
    gh.factory<_i469.AuthBloc>(() => _i469.AuthBloc(
          gh<_i466.SignIn>(),
          gh<_i466.Register>(),
          gh<_i466.SignOut>(),
          gh<_i466.CheckAuthStatusUseCase>(),
          gh<_i466.GetCurrentUser>(),
        ));
    gh.lazySingleton<_i1010.KnowledgeRepository>(
        () => _i490.KnowledgeRepositoryImpl(gh<_i97.KnowledgeService>()));
    gh.factory<_i1050.BreedingCubit>(() => _i1050.BreedingCubit(
          gh<_i320.GetBreedingRecords>(),
          gh<_i320.AddBreedingRecord>(),
          gh<_i320.DeleteBreedingRecord>(),
        ));
    gh.lazySingleton<_i422.InventoryRepository>(
        () => _i642.InventoryRepositoryImpl(
              gh<_i374.InventoryService>(),
              gh<_i761.ConnectivityService>(),
            ));
    gh.lazySingleton<_i894.ProfileRepository>(() => _i603.ProfileRepositoryImpl(
          gh<_i117.AuthService>(),
          gh<_i787.AuthRepository>(),
          gh<_i576.ApiService>(),
        ));
    gh.lazySingleton<_i781.GetProfile>(
        () => _i781.GetProfile(gh<_i91.ProfileRepository>()));
    gh.lazySingleton<_i781.Logout>(
        () => _i781.Logout(gh<_i91.ProfileRepository>()));
    gh.lazySingleton<_i781.GetAuditEvents>(
        () => _i781.GetAuditEvents(gh<_i91.ProfileRepository>()));
    gh.lazySingleton<_i739.GetWeather>(
        () => _i739.GetWeather(gh<_i956.WeatherRepository>()));
    gh.factory<_i60.MarketplaceBloc>(() => _i60.MarketplaceBloc(
          gh<_i496.GetProducts>(),
          gh<_i496.AddProduct>(),
          gh<_i496.UpdateProduct>(),
          gh<_i496.DeleteProduct>(),
        ));
    gh.factory<_i734.AnimalsBloc>(() => _i734.AnimalsBloc(
          gh<_i483.GetAnimals>(),
          gh<_i483.AddAnimal>(),
          gh<_i483.UpdateAnimal>(),
          gh<_i483.DeleteAnimal>(),
        ));
    gh.factory<_i345.ProductionLogCubit>(() => _i345.ProductionLogCubit(
          gh<_i90.GetProductionLogs>(),
          gh<_i90.AddProductionLog>(),
          gh<_i90.DeleteProductionLog>(),
        ));
    gh.lazySingleton<_i415.SalesRepository>(() => _i379.SalesRepositoryImpl(
          gh<_i970.SaleService>(),
          gh<_i422.InventoryRepository>(),
        ));
    gh.lazySingleton<_i8.GetInventory>(
        () => _i8.GetInventory(gh<_i507.InventoryRepository>()));
    gh.lazySingleton<_i8.DeleteInventoryItem>(
        () => _i8.DeleteInventoryItem(gh<_i507.InventoryRepository>()));
    gh.lazySingleton<_i8.ResolveInventoryConflictKeepLocal>(() =>
        _i8.ResolveInventoryConflictKeepLocal(gh<_i507.InventoryRepository>()));
    gh.lazySingleton<_i8.ResolveInventoryConflictUseServer>(() =>
        _i8.ResolveInventoryConflictUseServer(gh<_i507.InventoryRepository>()));
    gh.lazySingleton<_i156.GetDashboardData>(() => _i156.GetDashboardData(
          gh<_i873.FarmSummaryRepository>(),
          gh<_i739.GetWeather>(),
        ));
    gh.lazySingleton<_i149.GetSales>(
        () => _i149.GetSales(gh<_i415.SalesRepository>()));
    gh.lazySingleton<_i149.AddSale>(
        () => _i149.AddSale(gh<_i415.SalesRepository>()));
    gh.lazySingleton<_i149.UpdateSale>(
        () => _i149.UpdateSale(gh<_i415.SalesRepository>()));
    gh.lazySingleton<_i149.DeleteSale>(
        () => _i149.DeleteSale(gh<_i415.SalesRepository>()));
    gh.factory<_i495.HomeBloc>(
        () => _i495.HomeBloc(gh<_i156.GetDashboardData>()));
    gh.factory<_i224.AuditEventsCubit>(
        () => _i224.AuditEventsCubit(gh<_i781.GetAuditEvents>()));
    gh.lazySingleton<_i8.AddInventoryItem>(() => _i8.AddInventoryItem(
          gh<_i507.InventoryRepository>(),
          gh<_i468.DomainEventBus>(),
        ));
    gh.lazySingleton<_i8.UpdateInventoryItem>(() => _i8.UpdateInventoryItem(
          gh<_i507.InventoryRepository>(),
          gh<_i468.DomainEventBus>(),
        ));
    gh.lazySingleton<_i734.GetKnowledgeTopics>(
        () => _i734.GetKnowledgeTopics(gh<_i1010.KnowledgeRepository>()));
    gh.factory<_i953.SalesBloc>(() => _i953.SalesBloc(
          gh<_i149.GetSales>(),
          gh<_i149.AddSale>(),
          gh<_i149.UpdateSale>(),
          gh<_i149.DeleteSale>(),
        ));
    gh.factory<_i400.WeatherCubit>(
        () => _i400.WeatherCubit(gh<_i739.GetWeather>()));
    gh.factory<_i717.ProfileBloc>(() => _i717.ProfileBloc(
          gh<_i781.GetProfile>(),
          gh<_i781.Logout>(),
        ));
    gh.factory<_i263.KnowledgeCubit>(
        () => _i263.KnowledgeCubit(gh<_i734.GetKnowledgeTopics>()));
    gh.factory<_i1046.InventoryBloc>(() => _i1046.InventoryBloc(
          gh<_i8.GetInventory>(),
          gh<_i8.AddInventoryItem>(),
          gh<_i8.UpdateInventoryItem>(),
          gh<_i8.DeleteInventoryItem>(),
          gh<_i8.ResolveInventoryConflictKeepLocal>(),
          gh<_i8.ResolveInventoryConflictUseServer>(),
        ));
    return this;
  }
}
