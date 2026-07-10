<?php

namespace App\Http\Controllers\Api;


use App\Http\Controllers\Controller;
use App\Models\Appointment;
use App\Models\Doctor;
use Illuminate\Http\Request;

class AppointmentController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'patient_id' => 'required',
            'doctor_id' => 'required',
            'appointment_date' => 'required'
        ]);

        $appointment = Appointment::create([
            'patient_id' => $request->patient_id,
            'doctor_id' => $request->doctor_id,
            'appointment_date' => $request->appointment_date,
            'status' => 'pending'
        ]);

        return response()->json([
            'message' => 'Appointment booked successfully',
            'appointment' => $appointment
        ]);
    }
   public function patientAppointments($patientId)
{
    $appointments = Appointment::with([
        'doctor.user',
        'doctor.specialty'
    ])
    ->where('patient_id', $patientId)
    ->get();

    return $appointments->map(function ($appointment) {
        return [
            'id' => $appointment->id,
            'doctor_name' => $appointment->doctor->user->full_name,
            'doctor_image' => $appointment->doctor->image,
            'specialty' => $appointment->doctor->specialty->name,
            'appointment_date' => $appointment->appointment_date,
            'status' => $appointment->status,
            'doctor_notes' => $appointment->doctor_notes,
        ];
    });
}
public function doctorAppointments($userId)
{
    $doctor = Doctor::where('user_id', $userId)
        ->firstOrFail();

    $appointments = Appointment::with('patient')
        ->where('doctor_id', $doctor->id)
        ->orderBy('appointment_date')
        ->get();

    return $appointments->map(function ($appointment) {
        return [
            'appointment_id' => $appointment->id,

            'patient_id' => $appointment->patient->id,

            'patient_name' => $appointment->patient->full_name,

            'patient_image' => $appointment->patient->image,

            'patient_phone' => $appointment->patient->phone,

            'appointment_date' => $appointment->appointment_date,

            'status' => $appointment->status,

            'doctor_notes' => $appointment->doctor_notes,
        ];
    });
}

public function update(Request $request, $id)
{
    $appointment = Appointment::findOrFail($id);

    $request->validate([
        'status' => 'required|in:pending,confirmed,completed,cancelled',
        'doctor_notes' => 'nullable|string'
    ]);

    $appointment->update([
        'status' => $request->status,
        'doctor_notes' => $request->doctor_notes
    ]);

    return response()->json([
        'message' => 'Appointment updated successfully',
        'appointment' => $appointment
    ]);
}
}