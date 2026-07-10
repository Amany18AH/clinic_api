<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Doctor;
use App\Models\Specialty;
use App\Models\Appointment;
use Illuminate\Http\Request;

class PatientHomeController extends Controller
{
    public function index($patientId)
{
    // بيانات المريض
    $patient = User::find($patientId);

    // أقرب موعد
    $appointment = Appointment::with(['doctor.user', 'doctor.specialty'])
        ->where('patient_id', $patientId)
        ->orderBy('appointment_date', 'asc')
        ->first();

    // جميع التخصصات
    $specialties = Specialty::select('id', 'name')->get();

    // جميع الأطباء
    $doctors = Doctor::with(['user', 'specialty'])->get();

    // تجهيز بيانات الأطباء
    $doctorList = [];

    foreach ($doctors as $doctor) {

        $doctorList[] = [

            'id' => $doctor->id,

            'name' => $doctor->user->full_name,

            'image' => $doctor->user->image,

            'specialty' => $doctor->specialty->name,

            'consultation_fee' => $doctor->consultation_fee,

            'experience_years' => $doctor->experience_years,

            'about' => $doctor->about,
        ];
    }

    return response()->json([

        'patient' => [

            'id' => $patient->id,

            'name' => $patient->full_name,

            'image' => $patient->image,
        ],

        'upcoming_appointment' => $appointment ? [

            'doctor_name' => $appointment->doctor->user->full_name,

            'doctor_image' => $appointment->doctor->user->image,

            'specialty' => $appointment->doctor->specialty->name,

            'appointment_date' => $appointment->appointment_date,

            'status' => $appointment->status,

        ] : null,

        'specialties' => $specialties,

        'doctors' => $doctorList,

    ]);
}
}