package com.iqbot.flutter

import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import android.view.accessibility.AccessibilityManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.iqbot.flutter/bot"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    "startBot" -> {
                        val imagePath  = call.argument<String>("imagePath") ?: ""
                        val intervalSec = call.argument<Int>("intervalSec") ?: 120
                        val confidence = call.argument<Double>("confidence") ?: 0.8

                        // Pass config to accessibility service
                        BotAccessibilityService.getInstance()?.startBot(
                            imagePath, intervalSec, confidence.toFloat()
                        )

                        // Start overlay
                        val intent = Intent(this, OverlayService::class.java)
                        intent.putExtra("intervalSec", intervalSec)
                        startForegroundService(intent)

                        result.success(true)
                    }

                    "stopBot" -> {
                        BotAccessibilityService.getInstance()?.stopBot()
                        stopService(Intent(this, OverlayService::class.java))
                        result.success(true)
                    }

                    "findAndTap" -> {
                        val imagePath  = call.argument<String>("imagePath") ?: ""
                        val confidence = call.argument<Double>("confidence") ?: 0.8

                        val service = BotAccessibilityService.getInstance()
                        if (service == null) {
                            result.error("NO_SERVICE",
                                "Accessibility service not running", null)
                            return@setMethodCallHandler
                        }

                        service.findAndTap(imagePath, confidence.toFloat()) { success ->
                            result.success(success)
                        }
                    }

                    "isAccessibilityEnabled" -> {
                        result.success(isAccessibilityEnabled())
                    }

                    "openAccessibilitySettings" -> {
                        startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                        result.success(true)
                    }

                    "openOverlaySettings" -> {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName"))
                        startActivity(intent)
                        result.success(true)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun isAccessibilityEnabled(): Boolean {
        val am = getSystemService(ACCESSIBILITY_SERVICE) as AccessibilityManager
        val services = am.getEnabledAccessibilityServiceList(
            AccessibilityServiceInfo.FEEDBACK_ALL_MASK)
        return services.any { it.id.contains(packageName) }
    }
}
