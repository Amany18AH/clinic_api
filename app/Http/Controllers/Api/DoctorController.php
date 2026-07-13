<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Doctor;
use App\Models\Appointment;
use Carbon\Carbon;

class DoctorController extends Controller
{
    public function index()
    {
        $doctors = Doctor::with(['user', 'specialty'])->get();

        return response()->json(
            $doctors->map(function ($doctor) {
                return [
                    'id' => $doctor->id,
                    'user_id' => $doctor->user->id,

                    'name' => $doctor->user->full_name,

                    'image' => $doctor->user->image,

                    'specialty_id' => $doctor->specialty->id,

                    'specialty' => $doctor->specialty->name,

                    'consultation_fee' => $doctor->consultation_fee,
                    'experience_years' => $doctor->experience_years,
                    'about' => $doctor->about,
                ];
            })
        );
    }


    public function home($userId)
{
    $doctor = Doctor::with([
        'user',
        'specialty',
    ])
    ->where('user_id', $userId)
    ->firstOrFail();

    $doctorId = $doctor->id;


    $todayAppointments = Appointment::where('doctor_id', $doctorId)
        ->whereDate('appointment_date', \Carbon\Carbon::today());

    return response()->json([
        'doctor' => [
            'id' => $doctor->id,
            'name' => $doctor->user->full_name,
            'image' => $doctor->user->image,
            'specialty' => $doctor->specialty->name,
        ],

        'summary' => [
            'today_appointments' => (clone $todayAppointments)->count(),

            'pending' => (clone $todayAppointments)
                ->where('status', 'pending')
                ->count(),

            'completed' => (clone $todayAppointments)
                ->where('status', 'completed')
                ->count(),
        ],

        'today_appointments' => Appointment::with('patient')
            ->where('doctor_id', $doctorId)
            ->whereDate('appointment_date', \Carbon\Carbon::today())
            ->orderBy('appointment_date')
            ->get()
            ->map(function ($appointment) {
                return [
                    'appointment_id' => $appointment->id,
                    'patient_name' => $appointment->patient->full_name,
                    'appointment_date' => $appointment->appointment_date,
                    'status' => $appointment->status,
                ];
            }),
    ]);
}


public function patients($userId)
{

    $doctor = Doctor::where(
        'user_id',
        $userId,
    )->firstOrFail();

    $doctorId = $doctor->id;

    $patients = Appointment::with('patient')
        ->where('doctor_id', $doctorId)
        ->get()
        ->unique('patient_id')
        ->map(function ($appointment) {

            $patient = $appointment->patient;

            return [
                'id' => $patient->id,
                'name' => $patient->full_name,
                'image' => $patient->image,
                'phone' => $patient->phone,
            ];
        })
        ->values();

    return response()->json($patients);
}



}
