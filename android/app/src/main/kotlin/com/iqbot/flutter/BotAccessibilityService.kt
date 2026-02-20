package com.iqbot.flutter

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.graphics.Bitmap
import android.graphics.Path
import android.os.Handler
import android.os.Looper
import android.view.accessibility.AccessibilityEvent
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class BotAccessibilityService : AccessibilityService() {

    companion object {
        private var instance: BotAccessibilityService? = null
        fun getInstance() = instance
    }

    private val executor: ExecutorService = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())
    private var running = false

    override fun onServiceConnected() {
        instance = this
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
        executor.shutdown()
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {}
    override fun onInterrupt() { running = false }

    fun startBot(imagePath: String, intervalSec: Int, confidence: Float) {
        running = true
    }

    fun stopBot() {
        running = false
    }

    fun findAndTap(imagePath: String, confidence: Float, callback: (Boolean) -> Unit) {
        executor.execute {
            val screen = takeScreenshotBitmap()
            if (screen == null) {
                mainHandler.post { callback(false) }
                return@execute
            }

            val template = ImageUtils.loadBitmap(applicationContext, imagePath)
            if (template == null) {
                mainHandler.post { callback(false) }
                return@execute
            }

            val location = ImageUtils.findTemplate(screen, template, confidence)
            screen.recycle()
            template.recycle()

            if (location != null) {
                performTap(location[0], location[1])
                // Vibrate
                try {
                    val v = getSystemService(VIBRATOR_SERVICE) as android.os.Vibrator
                    v.vibrate(80)
                } catch (e: Exception) {}
                mainHandler.post { callback(true) }
            } else {
                mainHandler.post { callback(false) }
            }
        }
    }

    private fun takeScreenshotBitmap(): Bitmap? {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
            var result: Bitmap? = null
            val lock = Object()
            takeScreenshot(android.view.Display.DEFAULT_DISPLAY, mainExecutor,
                object : TakeScreenshotCallback {
                    override fun onSuccess(s: ScreenshotResult) {
                        result = Bitmap.wrapHardwareBuffer(s.hardwareBuffer, null)
                            ?.copy(Bitmap.Config.ARGB_8888, false)
                        s.hardwareBuffer.close()
                        synchronized(lock) { lock.notifyAll() }
                    }
                    override fun onFailure(e: Int) {
                        synchronized(lock) { lock.notifyAll() }
                    }
                })
            synchronized(lock) { lock.wait(3000) }
            return result
        }
        return null
    }

    private fun performTap(x: Int, y: Int) {
        val path = Path().apply { moveTo(x.toFloat(), y.toFloat()) }
        val stroke = GestureDescription.StrokeDescription(path, 0, 100)
        val gesture = GestureDescription.Builder().addStroke(stroke).build()
        dispatchGesture(gesture, null, null)
    }
}
