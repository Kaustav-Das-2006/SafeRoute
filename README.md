# 📍 SafeRoute - Real-Time Location Tracker

![Status](https://img.shields.io/badge/status-active-green) ![Tech](https://img.shields.io/badge/tech-WebSockets-blueviolet) ![Map](https://img.shields.io/badge/map-OpenStreetMap-brightgreen)

## 📖 Overview

**SafeRoute** is a full-stack real-time location tracking system. It demonstrates how to handle bi-directional data streams between a mobile app and a backend server with millisecond latency.

Unlike standard REST API polling (which is slow), this project uses **WebSockets** to push location updates instantly. It visualizes the data on a professional **OpenStreetMap** interface using the "Voyager" dark/light theme.

## ✨ Key Features

- **📡 Real-Time Communication:** Uses persistent WebSocket connections for zero-latency updates.
- **🗺️ Professional Mapping:** Implements OpenStreetMap with the CartoDB Voyager theme (no API keys required).
- **🔄 Bi-Directional Stream:** The server echoes driver data to the dashboard instantly.
- **📱 Cross-Platform:** Flutter client works on Android & iOS.

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)
  - `flutter_map` for rendering OSM tiles.
  - `web_socket_channel` for stream handling.
  - `geolocator` for GPS sensor access.
- **Backend:** Python (FastAPI)
  - `fastapi.websockets` for connection management.
  - `uvicorn` for high-performance ASGI server.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- Python 3.9+

### Installation

#### 1. Backend Setup

The backend handles the active socket connections.

```bash
cd backend
# Create virtual env
python -m venv venv
# Activate it (Windows: venv\Scripts\activate, Mac/Linux: source venv/bin/activate)

# Install dependencies
pip install -r requirements.txt

# Run the WebSocket server
uvicorn main:app --reload --host 0.0.0.0 --port 8000
2. Frontend Setup
The mobile app acts as the "Driver" or "Tracker."

Bash

cd frontend
flutter pub get
flutter run
Note: If running on an Android Emulator, ensure you set a simulated route via the Emulator settings to see the movement.

🧠 Architecture
Trigger: The mobile device detects a GPS location change.

Transmit: The app sends a JSON packet (lat, lng, id) via ws:// protocol.

Broadcast: The FastAPI server receives the packet and instantly pushes it to all connected clients (Admin Dashboard).

Visualize: The map updates the marker position in real-time without a page refresh.

📞 Contact
Kaustav Das

GitHub: Kaustav-Das-2006
```
