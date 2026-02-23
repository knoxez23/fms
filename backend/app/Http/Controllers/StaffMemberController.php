<?php

namespace App\Http\Controllers;

use App\Http\Requests\StaffMember\StoreStaffMemberRequest;
use App\Http\Requests\StaffMember\UpdateStaffMemberRequest;
use App\Http\Resources\StaffMemberResource;
use App\Models\StaffMember;
use App\Services\Farm\StaffMemberService;

class StaffMemberController extends Controller
{
    public function __construct(private readonly StaffMemberService $staffMemberService)
    {
    }

    public function index()
    {
        $items = $this->staffMemberService->listForUser((int) auth()->id());

        return $items->map(fn (StaffMember $item) => (new StaffMemberResource($item))->resolve())->values();
    }

    public function store(StoreStaffMemberRequest $request)
    {
        $created = $this->staffMemberService->createForUser((int) auth()->id(), $request->validated());

        return (new StaffMemberResource($created))->response()->setStatusCode(201);
    }

    public function show(string $id)
    {
        $item = $this->staffMemberService->showForUser((int) auth()->id(), $id);

        return new StaffMemberResource($item);
    }

    public function update(UpdateStaffMemberRequest $request, string $id)
    {
        $item = $this->staffMemberService->updateForUser((int) auth()->id(), $id, $request->validated());

        return new StaffMemberResource($item);
    }

    public function destroy(string $id)
    {
        $this->staffMemberService->deleteForUser((int) auth()->id(), $id);

        return response()->noContent();
    }
}
