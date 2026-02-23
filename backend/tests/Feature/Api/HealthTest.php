<?php

test('public health endpoint exposes service status', function () {
    $response = $this->getJson('/api/v1/health');

    $response->assertOk()
        ->assertHeader('X-Content-Type-Options', 'nosniff')
        ->assertHeader('X-Frame-Options', 'DENY')
        ->assertHeader('Referrer-Policy', 'strict-origin-when-cross-origin')
        ->assertHeader('X-Request-Id')
        ->assertJsonStructure([
            'status',
            'timestamp',
            'services' => ['database'],
            'app' => ['env', 'version'],
        ]);
});
