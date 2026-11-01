# Spotless

Spotless is a Flutter app that talks to the backend in the `spotless_backend` folder.

## Same Wi‑Fi setup for mobile + laptop

To make the app work across devices connected to the same Wi‑Fi network:

1. Start the backend on the laptop that is hosting the database:
   - Open a terminal in `spotless_backend`
   - Run `npm install`
   - Run `node server.js`
2. Check the laptop's local IP address on the same Wi‑Fi, for example `192.168.1.24`.
3. Run the app with that backend URL if needed:
   - `flutter run --dart-define=API_BASE_URL=http://192.168.1.24:3000`
4. On Android devices or laptops, the app will also try to detect a local LAN IP automatically when no saved override is configured.

## Notes

- The backend listens on `0.0.0.0:3000`, so it is available on the local network.
- The app prefers a saved custom URL, then a LAN IP from the current device, then the emulator fallback (`10.0.2.2`).
- For local development, `localhost` still works when the app and backend run on the same machine.
