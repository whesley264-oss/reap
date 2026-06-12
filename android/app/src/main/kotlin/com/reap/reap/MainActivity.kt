package com.reap.reap

import android.Manifest
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.content.pm.PackageManager.NameNotFoundException
import android.os.BatteryManager
import android.os.Build
import android.os.Environment
import android.os.StatFs
import android.os.SystemClock
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.reap/native"
    private val STORAGE_PERMISSION_CODE = 1001

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceInfo" -> result.success(getDeviceInfo())
                "getBatteryInfo" -> result.success(getBatteryInfo())
                "getStorageAnalysis" -> result.success(getStorageAnalysis())
                "getInstalledApps" -> result.success(getInstalledApps())
                "getAndroidVersion" -> result.success(Build.VERSION.SDK_INT)
                "hasStoragePermission" -> result.success(checkStoragePermission())
                "requestStoragePermission" -> {
                    requestStoragePermission()
                    result.success(true)
                }
                "getRealStorageInfo" -> result.success(getRealStorageInfo())
                else -> result.notImplemented()
            }
        }
    }

    private fun checkStoragePermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            Environment.isExternalStorageManager()
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.READ_MEDIA_VIDEO
            ) == PackageManager.PERMISSION_GRANTED
        } else {
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.READ_EXTERNAL_STORAGE
            ) == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun requestStoragePermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                val intent = Intent(android.provider.Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)
                intent.data = android.net.Uri.parse("package:$packageName")
                startActivityForResult(intent, STORAGE_PERMISSION_CODE)
            } catch (e: Exception) {
                val intent = Intent(android.provider.Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION)
                startActivityForResult(intent, STORAGE_PERMISSION_CODE)
            }
        } else {
            val permissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                arrayOf(
                    Manifest.permission.READ_MEDIA_VIDEO,
                    Manifest.permission.READ_MEDIA_IMAGES,
                    Manifest.permission.READ_MEDIA_AUDIO
                )
            } else {
                arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE)
            }
            ActivityCompat.requestPermissions(this, permissions, STORAGE_PERMISSION_CODE)
        }
    }

    private fun getRealStorageInfo(): Map<String, Any> {
        var totalBytes: Long = 0
        var freeBytes: Long = 0

        try {
            val path = Environment.getExternalStorageDirectory()
            val stat = StatFs(path.path)
            totalBytes = stat.blockSizeLong * stat.blockCountLong
            freeBytes = stat.blockSizeLong * stat.availableBlocksLong
        } catch (e: Exception) {
            // Fallback - use internal storage
            val path = Environment.getDataDirectory()
            val stat = StatFs(path.path)
            totalBytes = stat.blockSizeLong * stat.blockCountLong
            freeBytes = stat.blockSizeLong * stat.availableBlocksLong
        }

        return mapOf(
            "totalStorage" to totalBytes,
            "freeStorage" to freeBytes,
            "usedStorage" to (totalBytes - freeBytes)
        )
    }

    private fun getDeviceInfo(): Map<String, Any> {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memInfo = ActivityManager.MemoryInfo()
        activityManager.getMemoryInfo(memInfo)

        val totalRam = memInfo.totalMem
        val freeRam = memInfo.availMem
        val uptime = SystemClock.elapsedRealtime() / 1000

        // Get real storage info
        val storageInfo = getRealStorageInfo()
        val totalStorage = storageInfo["totalStorage"] as Long
        val freeStorage = storageInfo["freeStorage"] as Long

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
            "cpuCores" to cpuCores,
            "hasStoragePermission" to checkStoragePermission()
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

        // Estimate battery health based on actual battery properties
        // Note: Android doesn't expose true battery health to apps without special permissions
        // We can only estimate based on temperature and general behavior
        var estimatedHealth = 85 // Default estimate
        var healthConfidence = "low"

        // Adjust based on temperature - high temp degrades battery
        if (temperature > 0) {
            when {
                temperature < 30 -> {
                    estimatedHealth = 90
                    healthConfidence = "high"
                }
                temperature < 40 -> {
                    estimatedHealth = 85
                    healthConfidence = "high"
                }
                temperature < 45 -> {
                    estimatedHealth = 75
                    healthConfidence = "medium"
                }
                else -> {
                    estimatedHealth = 65
                    healthConfidence = "medium"
                }
            }
        }

        return mapOf(
            "level" to batteryPct,
            "temperature" to temperature,
            "status" to status,
            "voltage" to voltage,
            "technology" to technology,
            "estimatedHealth" to estimatedHealth,
            "healthConfidence" to healthConfidence,
            "isCharging" to (statusInt == BatteryManager.BATTERY_STATUS_CHARGING)
        )
    }

    private fun getStorageAnalysis(): List<Map<String, Any>> {
        val categories = mutableListOf<Map<String, Any>>()

        // Check if we have permission first
        if (!checkStoragePermission()) {
            return listOf(
                mapOf(
                    "category" to "permission_required",
                    "message" to "Permissão de armazenamento necessária",
                    "size" to 0L,
                    "count" to 0,
                    "percentage" to 0.0
                )
            )
        }

        val dcimDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM)
        val picturesDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
        val videosDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES)
        val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        val musicDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MUSIC)
        val documentsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS)
        val podcastDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PODCASTS)
        val alarmsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_ALARMS)
        val downloadsFolder = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)

        categories.add(analyzeDirectory("videos", videosDir))
        categories.add(analyzeDirectory("images", dcimDir, picturesDir))
        categories.add(analyzeDirectory("downloads", downloadsDir, downloadsFolder))
        categories.add(analyzeDirectory("audio", musicDir, podcastDir))
        categories.add(analyzeDirectory("documents", documentsDir))
        categories.add(analyzeDirectory("alarms", alarmsDir))

        // Calculate total size and percentages
        val totalSize = categories.filter { it["category"] != "permission_required" }
            .sumOf { it["size"] as Long }

        categories.forEach { category ->
            if (totalSize > 0) {
                val percentage = ((category["size"] as Long) * 100.0 / totalSize)
                (category as MutableMap)["percentage"] = percentage
            }
        }

        return categories
    }

    private fun analyzeDirectory(category: String, vararg dirs: File): Map<String, Any> {
        var totalSize = 0L
        var count = 0

        for (dir in dirs) {
            try {
                if (dir.exists() && dir.isDirectory && dir.canRead()) {
                    dir.walkTopDown().forEach { file ->
                        if (file.isFile && !file.name.startsWith(".")) {
                            try {
                                totalSize += file.length()
                                count++
                            } catch (e: Exception) {
                                // Skip files we can't read
                            }
                        }
                    }
                }
            } catch (e: Exception) {
                // Skip directories we can't access
            }
        }

        return mutableMapOf(
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
            .mapNotNull { appInfo ->
                try {
                    val packageName = appInfo.packageName
                    val appName = pm.getApplicationLabel(appInfo).toString()
                    val installTime = packageManager.getPackageInfo(packageName, 0).firstInstallTime
                    val lastUpdateTime = packageManager.getPackageInfo(packageName, 0).lastUpdateTime

                    // Get app size properly
                    val size = getAppSize(appInfo)

                    mapOf(
                        "packageName" to packageName,
                        "name" to appName,
                        "size" to size,
                        "installDate" to installTime,
                        "lastUpdate" to lastUpdateTime,
                        "version" to getAppVersion(packageName),
                        "isSystemApp" to false
                    )
                } catch (e: Exception) {
                    null
                }
            }
            .sortedByDescending { (it["size"] as? Long) ?: 0L }
    }

    private fun getAppSize(appInfo: ApplicationInfo): Long {
        var size: Long = 0
        try {
            // Primary source APK
            size += File(appInfo.sourceDir).length()

            // Split APKs (if any)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                appInfo.splitSourceDirs?.forEach { path ->
                    size += File(path).length()
                }
            }

            // Native libraries size (approximation)
            if (appInfo.nativeLibraryDir != null) {
                val nativeDir = File(appInfo.nativeLibraryDir)
                if (nativeDir.exists()) {
                    nativeDir.listFiles()?.forEach { file ->
                        size += file.length()
                    }
                }
            }
        } catch (e: Exception) {
            // Fallback
        }
        return size
    }

    private fun getAppVersion(packageName: String): String {
        return try {
            val pInfo = packageManager.getPackageInfo(packageName, 0)
            pInfo.versionName ?: "Unknown"
        } catch (e: NameNotFoundException) {
            "Unknown"
        }
    }
}
