// Use-cases for crop feature
import 'package:injectable/injectable.dart';
import 'package:pamoja_twalima/core/domain/events/domain_event_bus.dart';
import '../domain/repositories/repositories.dart';
import '../domain/entities/crop_entity.dart';
import '../domain/events/farm_domain_events.dart';

@lazySingleton
class GetCrops {
  final CropRepository repository;
  GetCrops(this.repository);

  Future<List<CropEntity>> execute() async => await repository.getCrops();
}

@lazySingleton
class AddCrop {
  final CropRepository repository;
  final DomainEventBus _eventBus;
  AddCrop(this.repository, this._eventBus);

  Future<CropEntity> execute(CropEntity crop) async {
    final created = await repository.addCrop(crop);
    if (created.isReadyForHarvest) {
      _eventBus.publish(
        CropHarvested(
          cropId: created.id,
          cropName: created.name.value,
        ),
      );
    }
    return created;
  }
}

@lazySingleton
class UpdateCrop {
  final CropRepository repository;
  final DomainEventBus _eventBus;
  UpdateCrop(this.repository, this._eventBus);

  Future<CropEntity> execute(CropEntity crop) async {
    final updated = await repository.updateCrop(crop);
    if (updated.isReadyForHarvest) {
      _eventBus.publish(
        CropHarvested(
          cropId: updated.id,
          cropName: updated.name.value,
        ),
      );
    }
    return updated;
  }
}

@lazySingleton
class DeleteCrop {
  final CropRepository repository;
  DeleteCrop(this.repository);

  Future<void> execute(String id) async => await repository.deleteCrop(id);
}
