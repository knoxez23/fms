<?php

namespace Database\Factories;

use App\Models\Inventory;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class InventoryFactory extends Factory
{
    protected $model = Inventory::class;

    public function definition(): array
    {
        return [
            'item_name' => $this->faker->words(2, true),
            'category' => $this->faker->randomElement(['Feed', 'Medicine', 'Tools', 'Seeds']),
            'quantity' => $this->faker->randomFloat(2, 1, 500),
            'unit' => $this->faker->randomElement(['kg', 'liters', 'bags', 'units']),
            'min_stock' => $this->faker->numberBetween(0, 50),
            'supplier' => $this->faker->company(),
            'unit_price' => $this->faker->randomFloat(2, 1, 100),
            'total_value' => $this->faker->randomFloat(2, 10, 5000),
            'notes' => $this->faker->sentence(),
            'last_restock' => $this->faker->dateTimeThisYear(),
            'is_synced' => true,
            'server_id' => null,
            'user_id' => User::factory(),
        ];
    }
}
