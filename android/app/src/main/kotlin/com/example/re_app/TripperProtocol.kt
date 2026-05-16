package com.example.re_app

import java.nio.charset.StandardCharsets

object TripperProtocol {
    // TLV Types
    const val TYPE_ROAD_NAME = 0x01
    const val TYPE_MANEUVER = 0x02
    const val TYPE_DISTANCE = 0x04
    const val TYPE_UNITS = 0x06
    const val TYPE_ETA = 0x08
    const val TYPE_TOTAL_DIST = 0x09

    // Status Commands
    val MUTE_MUSIC = byteArrayOf(0x05, 0x4C, 0x00, 0x01, 0x10)
    val MAX_MUSIC = byteArrayOf(0x05, 0x4C, 0x00, 0x01, 0x1A)
    
    fun createTextPacket(text: String, type: Int = TYPE_ROAD_NAME): ByteArray {
        val bytes = text.toByteArray(StandardCharsets.UTF_8)
        val length = bytes.size + 1 // +1 for null terminator
        val packet = ByteArray(3 + length)
        packet[0] = type.toByte()
        packet[1] = (length shr 8).toByte()
        packet[2] = (length and 0xFF).toByte()
        System.arraycopy(bytes, 0, packet, 3, bytes.size)
        packet[packet.size - 1] = 0x00 // Null terminator
        return packet
    }

    fun createDistancePacket(meters: Int): ByteArray {
        val packet = ByteArray(5)
        packet[0] = TYPE_DISTANCE.toByte()
        packet[1] = 0x00
        packet[2] = 0x02
        packet[3] = (meters shr 8).toByte()
        packet[4] = (meters and 0xFF).toByte()
        return packet
    }

    fun createArrowPacket(angle: Int, type: Int = 0x01): ByteArray {
        // angle in degrees (0-359)
        val packet = ByteArray(5)
        packet[0] = TYPE_MANEUVER.toByte()
        packet[1] = 0x00
        packet[2] = 0x02
        packet[3] = type.toByte() // 0x01 is arrow
        packet[4] = angle.toByte()
        return packet
    }

    fun createHeartbeat(battery: Int): ByteArray {
        val packet = ByteArray(5)
        packet[0] = 0x06
        packet[1] = 0x04
        packet[2] = 0x00
        packet[3] = 0x01
        packet[4] = (battery + 100).toByte() // Protocol offset
        return packet
    }
}
