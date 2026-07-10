<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Users table
        Schema::table('users', function (Blueprint $table) {
            $table->string('phone')->nullable()->after('email');
            $table->string('image')->nullable()->after('phone');
        });

        // Doctors table
        Schema::table('doctors', function (Blueprint $table) {
            $table->unsignedTinyInteger('experience_years')->nullable()->after('consultation_fee');
            $table->text('about')->nullable()->after('experience_years');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['phone', 'image']);
        });

        Schema::table('doctors', function (Blueprint $table) {
            $table->dropColumn(['experience_years', 'about']);
        });
    }
};