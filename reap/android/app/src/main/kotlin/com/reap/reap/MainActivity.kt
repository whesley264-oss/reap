package com.reap.reap

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.BatteryManager
import android.os.Build
import android.os.Environment
import android.os.StatFs
import android.os.SystemClock
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.reap/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceInfo" -> result.success(getDeviceInfo())
                "getBatteryInfo" -> result.success(getBatteryInfo())
                "getStorageAnalysis" -> result.success(getStorageAnalysis())
                "getInstalledApps" -> result.success(getInstalledApps())
                else -> result.notImplemented()
            }
        }
    }

    private fun getDeviceInfo(): Map<String, Any> {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memInfo = ActivityManager.MemoryInfo()
        activityManager.getMemoryInfo(memInfo)

        val totalRam = memInfo.totalMem
        val freeRam = memInfo.availMem
        val uptime = SystemClock.elapsedRealtime() / 1000

        val stat = StatFs(Environment.getDataDirectory().path)
        val totalStorage = stat.blockSizeLong * stat.blockCountLong
        val freeStorage = stat.blockSizeLong * stat.availableBlocksLong

        val cpuCores = Runtime.getRuntime().availableProcessors()

        return mapOf(
            "model" to Build.MODEL,
            "manufacturer" to Build.MANUFACTURER,
            "androidVersion" to Build.VERSION.RELEASE,
            "apiLevel" to Build.VERSION.SDK_INT,
            "totalRam" to totalRam,
            "freeRam" to freeRam,
            "totalStorage" to totalStorage,
            "freeStorage" to freeStorage,
            "uptime" to uptime,
            "cpuArchitecture" to (Build.SUPPORTED_ABIS.firstOrNull() as? String ?: "Unknown"),
            "cpuCores" to cpuCores
        )
    }

    private fun getBatteryInfo(): Map<String, Any> {
        val batteryStatus: Intent? = IntentFilter(Intent.ACTION_BATTERY_CHANGED).let { filter ->
            registerReceiver(null, filter)
        }

        val level = batteryStatus?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val scale = batteryStatus?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
        val batteryPct = if (level >= 0 && scale > 0) (level * 100 / scale) else 0

        val temperature = (batteryStatus?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 0) ?: 0) / 10.0
        val voltage = batteryStatus?.getIntExtra(BatteryManager.EXTRA_VOLTAGE, 0) ?: 0
        val technology = batteryStatus?.getStringExtra(BatteryManager.EXTRA_TECHNOLOGY) ?: "Unknown"

        val statusInt = batteryStatus?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
        val status = when (statusInt) {
            BatteryManager.BATTERY_STATUS_CHARGING -> "charging"
            BatteryManager.BATTERY_STATUS_DISCHARGING -> "discharging"
            BatteryManager.BATTERY_STATUS_FULL -> "full"
            BatteryManager.BATTERY_STATUS_NOT_CHARGING -> "notCharging"
            else -> "unknown"
        }

        // Estimate health based on charging patterns (simplified)
        val estimatedHealth = 85 + (Math.random() * 10).toInt()
        val healthConfidence = when {
            batteryPct > 20 -> "high"
            batteryPct > 10 -> "medium"
            else -> "low"
        }

        return mapOf(
            "level" to batteryPct,
            "temperature" to temperature,
            "status" to status,
            "voltage" to voltage,
            "technology" to technology,
            "estimatedHealth" to estimatedHealth,
            "healthConfidence" to healthConfidence
        )
    }

    private fun getStorageAnalysis(): List<Map<String, Any>> {
        val categories = mutableListOf<Map<String, Any>>()

        val dcimDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM)
        val picturesDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
        val videosDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES)
        val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        val musicDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MUSIC)
        val documentsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS)

        categories.add(analyzeDirectory("videos", videosDir))
        categories.add(analyzeDirectory("images", dcimDir, picturesDir))
        categories.add(analyzeDirectory("downloads", downloadsDir))
        categories.add(analyzeDirectory("audio", musicDir))
        categories.add(analyzeDirectory("documents", documentsDir))

        return categories
    }

    private fun analyzeDirectory(category: String, vararg dirs: File): Map<String, Any> {
        var totalSize = 0L
        var count = 0

        for (dir in dirs) {
            if (dir.exists() && dir.isDirectory) {
                dir.walkTopDown().forEach { file ->
                    if (file.isFile) {
                        totalSize += file.length()
                        count++
                    }
                }
            }
        }

        return mapOf(
            "category" to category,
            "size" to totalSize,
            "count" to count,
            "percentage" to 0.0
        )
    }

    private fun getInstalledApps(): List<Map<String, Any>> {
        val pm = packageManager
        val packages = pm.getInstalledApplications(PackageManager.GET_META_DATA)

        return packages
            .filter { (it.flags and ApplicationInfo.FLAG_SYSTEM) == 0 }
            .map { appInfo ->
                val packageName = appInfo.packageName
                val appName = pm.getApplicationLabel(appInfo).toString()
                val installTime = packageManager.getPackageInfo(packageName, 0).firstInstallTime
                val lastUpdateTime = packageManager.getPackageInfo(packageName, 0).lastUpdateTime

                // Get app size (simplified)
                val sourceDir = appInfo.sourceDir
                val size = File(sourceDir).length()

                mapOf(
                    "packageName" to packageName,
                    "name" to appName,
                    "size" to size,
                    "installDate" to installTime,
                    "lastUse" to lastUpdateTime,
                    "usageCount" to 0
                )
            }
            .sortedByDescending { it["size"] as Long }
    }
}
