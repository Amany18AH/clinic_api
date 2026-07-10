<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DoctorController;
use App\Http\Controllers\Api\AppointmentController;
use App\Http\Controllers\Api\PatientHomeController;

Route::get('/user', function (Request $request) {
    return $request->user();
});

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);


Route::get('/doctors', [DoctorController::class, 'index']);
Route::get(
    '/doctor/home/{doctorId}',
    [DoctorController::class, 'home']
);
Route::get(
    '/doctor/{doctorId}/patients',
    [DoctorController::class, 'patients']
);

Route::post('/appointments', [AppointmentController::class, 'store']);
Route::get(
    '/patient/{id}/appointments',
    [AppointmentController::class, 'patientAppointments']
);
Route::get(
    '/doctor/{id}/appointments',
    [AppointmentController::class, 'doctorAppointments']
);

Route::put(
    '/appointments/{id}',
    [AppointmentController::class, 'update']
);


Route::get('/patient/home/{patientId}', [PatientHomeController::class, 'index']);
