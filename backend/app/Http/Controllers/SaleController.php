<?php

namespace App\Http\Controllers;

use App\Http\Requests\Sale\StoreSaleRequest;
use App\Http\Requests\Sale\UpdateSaleRequest;
use App\Http\Resources\SaleResource;
use App\Models\Sale;
use App\Services\Farm\SaleService;

class SaleController extends Controller
{
    public function __construct(private readonly SaleService $saleService)
    {
    }

    public function index()
    {
        $sales = $this->saleService->listForUser((int) auth()->id());

        return $sales->map(fn (Sale $sale) => (new SaleResource($sale))->resolve())->values();
    }

    public function store(StoreSaleRequest $request)
    {
        $sale = $this->saleService->createForUser((int) auth()->id(), $request->validated());

        return (new SaleResource($sale))->response()->setStatusCode(201);
    }

    public function show(string $id)
    {
        $sale = $this->saleService->showForUser((int) auth()->id(), $id);

        return new SaleResource($sale);
    }

    public function update(UpdateSaleRequest $request, string $id)
    {
        $sale = $this->saleService->updateForUser((int) auth()->id(), $id, $request->validated());
        return new SaleResource($sale);
    }

    public function destroy(string $id)
    {
        $this->saleService->deleteForUser((int) auth()->id(), $id);
        return response()->noContent();
    }
}
