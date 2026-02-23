<?php

namespace App\Http\Controllers;

use App\Http\Requests\Customer\StoreCustomerRequest;
use App\Http\Requests\Customer\UpdateCustomerRequest;
use App\Http\Resources\CustomerResource;
use App\Models\Customer;
use App\Services\Farm\CustomerService;

class CustomerController extends Controller
{
    public function __construct(private readonly CustomerService $customerService)
    {
    }

    public function index()
    {
        $items = $this->customerService->listForUser((int) auth()->id());

        return $items->map(fn (Customer $item) => (new CustomerResource($item))->resolve())->values();
    }

    public function store(StoreCustomerRequest $request)
    {
        $created = $this->customerService->createForUser((int) auth()->id(), $request->validated());

        return (new CustomerResource($created))->response()->setStatusCode(201);
    }

    public function show(string $id)
    {
        $item = $this->customerService->showForUser((int) auth()->id(), $id);

        return new CustomerResource($item);
    }

    public function update(UpdateCustomerRequest $request, string $id)
    {
        $item = $this->customerService->updateForUser((int) auth()->id(), $id, $request->validated());

        return new CustomerResource($item);
    }

    public function destroy(string $id)
    {
        $this->customerService->deleteForUser((int) auth()->id(), $id);

        return response()->noContent();
    }
}
