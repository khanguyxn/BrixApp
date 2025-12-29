BrixBox iOS Demo — WiFi + GPS Delta + Comms/Host Display (v0.3)
==============================================================

Adds
----
- Displays comm capabilities (WiFi/BLE/5G/SAT) from device JSON: comm_caps
- Displays host targets (esp32/stm32/windows_ce) from device JSON: host_targets
- Provides an endpoint picker (ESP32 default + placeholders for STM32/Windows CE gateways)

Important note about STM32 / Windows CE
---------------------------------------
iOS cannot "talk to a bare STM32" directly unless that STM32 exposes an endpoint via:
- WiFi/Ethernet (preferred)
- USB-tether/network bridge
- or a gateway device

So in v0.3 we:
- display that those targets exist
- provide placeholder URLs that become real when those targets ship gateways
