<?php

namespace App\Http\Controllers;

use App\Http\Requests\Task\StoreTaskRequest;
use App\Http\Requests\Task\UpdateTaskRequest;
use App\Http\Resources\TaskResource;
use App\Models\Task;
use App\Services\Task\TaskService;

class TaskController extends Controller
{
    public function __construct(private readonly TaskService $taskService)
    {
    }

    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $tasks = $this->taskService->listForUser((int) auth()->id());
        return $tasks->map(fn (Task $task) => (new TaskResource($task))->resolve())->values();
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreTaskRequest $request)
    {
        $userId = (int) auth()->id();
        $clientUuid = $request->validated('client_uuid');
        $alreadyExists = is_string($clientUuid) && $clientUuid !== ''
            ? Task::where('user_id', $userId)->where('client_uuid', $clientUuid)->exists()
            : false;

        $task = $this->taskService->createForUser($userId, $request->validated());

        return (new TaskResource($task))
            ->response()
            ->setStatusCode($alreadyExists ? 200 : 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $task = $this->taskService->showForUser((int) auth()->id(), $id);
        return new TaskResource($task);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateTaskRequest $request, string $id)
    {
        $task = $this->taskService->updateForUser((int) auth()->id(), $id, $request->validated());

        return new TaskResource($task);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $this->taskService->deleteForUser((int) auth()->id(), $id);

        return response()->noContent();
    }
}
