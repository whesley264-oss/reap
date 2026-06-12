package com.reap.reap

import android.Manifest
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.content.pm.PackageManager.NameNotFoundException
import android.net.Uri
import android.os.BatteryManager
import android.os.Build
import android.os.Environment
import android.os.StatFs
import android.os.SystemClock
import android.provider.Settings
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
                "openAppSettings" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        openAppSettings(packageName)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "packageName required", null)
                    }
                }
                "openFileLocation" -> {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        openFileLocation(path)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "path required", null)
                    }
                }
                "openDownloads" -> {
                    openDownloads()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun checkStoragePermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            Environment.isExternalStorageManager()
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ContextCompat.checkSelfPermission(this, Manifest.permission.READ_MEDIA_VIDEO) == PackageManager.PERMISSION_GRANTED
        } else {
            ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun requestStoragePermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                val intent = Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)
                intent.data = Uri.parse("package:$packageName")
                startActivityForResult(intent, STORAGE_PERMISSION_CODE)
            } catch (e: Exception) {
                val intent = Intent(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION)
                startActivityForResult(intent, STORAGE_PERMISSION_CODE)
            }
        } else {
            val permissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                arrayOf(Manifest.permission.READ_MEDIA_VIDEO, Manifest.permission.READ_MEDIA_IMAGES, Manifest.permission.READ_MEDIA_AUDIO)
            } else {
                arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE)
            }
            ActivityCompat.requestPermissions(this, permissions, STORAGE_PERMISSION_CODE)
        }
    }

    private fun openAppSettings(packageName: String) {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        intent.data = Uri.parse("package:$packageName")
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun openFileLocation(path: String) {
        try {
            val file = File(path)
            val intent = Intent(Intent.ACTION_VIEW)
            val parentDir = file.parentFile ?: file
            intent.setDataAndType(Uri.fromFile(parentDir), "resource/folder")
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(Intent.createChooser(intent, "Abrir local"))
        } catch (e: Exception) {
            // Fallback: try to open with file manager
            val intent = Intent(Intent.ACTION_VIEW)
            intent.data = Uri.parse("file://$path")
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        }
    }

    private fun openDownloads() {
        val intent = Intent(Intent.ACTION_VIEW)
        intent.data = Uri.parse("content://com.android.providers.downloads.documents/")
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            startActivity(intent)
        } catch (e: Exception) {
            // Fallback to Downloads folder
            val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
            val intent2 = Intent(Intent.ACTION_VIEW)
            intent2.setDataAndType(Uri.fromFile(downloadsDir), "resource/folder")
            intent2.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(Intent.createChooser(intent2, "Abrir Downloads"))
        }
    }

    private fun getDeviceInfo(): Map<String, Any> {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memInfo = ActivityManager.MemoryInfo()
        activityManager.getMemoryInfo(memInfo)

        val totalRam = memInfo.totalMem
        val freeRam = memInfo.availMem
        val uptime = SystemClock.elapsedRealtime() / 1000

        // Get storage info - try external first, then internal
        var totalStorage: Long = 0
        var freeStorage: Long = 0

        try {
            val externalDir = Environment.getExternalStorageDirectory()
            if (externalDir.canRead()) {
                val stat = StatFs(externalDir.path)
                totalStorage = stat.blockSizeLong * stat.blockCountLong
                freeStorage = stat.blockSizeLong * stat.availableBlocksLong
            }
        } catch (e: Exception) {
            // Use internal storage
            val stat = StatFs(Environment.getDataDirectory().path)
            totalStorage = stat.blockSizeLong * stat.blockCountLong
            freeStorage = stat.blockSizeLong * stat.availableBlocksLong
        }

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
            "cpuArchitecture" to (Build.SUPPORTED_ABIS.firstOrNull() ?: "Unknown"),
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

        // Estimate battery health based on temperature
        var estimatedHealth = 85
        var healthConfidence = "low"

        if (temperature > 0) {
            when {
                temperature < 30 -> { estimatedHealth = 92; healthConfidence = "high" }
                temperature < 40 -> { estimatedHealth = 88; healthConfidence = "high" }
                temperature < 45 -> { estimatedHealth = 75; healthConfidence = "medium" }
                else -> { estimatedHealth = 65; healthConfidence = "medium" }
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

        if (!checkStoragePermission()) {
            return listOf(mapOf("category" to "permission_required", "message" to "Permissão necessária", "size" to 0L, "count" to 0, "percentage" to 0.0))
        }

        // Define categories with their directories
        val categoryDirs = mapOf(
            "videos" to listOf(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES)),
            "images" to listOf(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM), 
                              Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)),
            "downloads" to listOf(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)),
            "audio" to listOf(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MUSIC), 
                             Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PODCASTS)),
            "documents" to listOf(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS)),
            "alarms" to listOf(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_ALARMS)),
            "ringtones" to listOf(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_RINGTONES))
        )

        for ((category, dirs) in categoryDirs) {
            val analyzed = analyzeDirectory(category, dirs.toTypedArray())
            if (analyzed["size"] as Long > 0) {
                categories.add(analyzed)
            }
        }

        // Calculate percentages
        val totalSize = categories.sumOf { it["size"] as Long }
        categories.forEach { cat ->
            if (totalSize > 0) {
                (cat as MutableMap)["percentage"] = ((cat["size"] as Long) * 100.0 / totalSize)
            }
        }

        return categories.sortedByDescending { it["size"] as Long }
    }

    private fun analyzeDirectory(category: String, dirs: Array<File>): Map<String, Any> {
        var totalSize = 0L
        var count = 0

        for (dir in dirs) {
            try {
                if (dir.exists() && dir.isDirectory && dir.canRead()) {
                    dir.walkTopDown().filter { it.isFile && !it.name.startsWith(".") }
                        .forEach { file ->
                            try {
                                totalSize += file.length()
                                count++
                            } catch (e: Exception) { /* skip */ }
                        }
                }
            } catch (e: Exception) { /* skip */ }
        }

        return mutableMapOf("category" to category, "size" to totalSize, "count" to count, "percentage" to 0.0)
    }

    private fun getInstalledApps(): List<Map<String, Any>> {
        val pm = packageManager
        
        return pm.getInstalledApplications(PackageManager.GET_META_DATA)
            .filter { (it.flags and ApplicationInfo.FLAG_SYSTEM) == 0 }
            .mapNotNull { appInfo ->
                try {
                    val packageName = appInfo.packageName
                    val pInfo = pm.getPackageInfo(packageName, 0)
                    
                    mapOf(
                        "packageName" to packageName,
                        "name" to pm.getApplicationLabel(appInfo).toString(),
                        "size" to calculateAppSize(appInfo),
                        "installDate" to pInfo.firstInstallTime,
                        "lastUpdate" to pInfo.lastUpdateTime,
                        "version" to (pInfo.versionName ?: "Unknown"),
                        "versionCode" to pInfo.versionCode,
                        "isSystemApp" to ((appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0)
                    )
                } catch (e: Exception) { null }
            }
            .sortedByDescending { (it["size"] as? Long) ?: 0L }
    }

    private fun calculateAppSize(appInfo: ApplicationInfo): Long {
        var size: Long = 0
        try {
            // Main APK
            size += File(appInfo.sourceDir).length()
            
            // Split APKs (bundled)
            appInfo.splitSourceDirs?.forEach { size += File(it).length() }
            
            // External data (if any)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.GINGERBREAD) {
                try {
                    val pex = File(appInfo.dataDir + "/split_lib_metadata_")
                    if (pex.exists()) size += pex.length()
                } catch (e: Exception) { /* ignore */ }
            }
        } catch (e: Exception) { /* ignore */ }
        return size
    }
}
