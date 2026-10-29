# AutoServisAA

Information system for an auto service: client mobile app (Flutter, Android), administrative desktop app (Flutter Windows),
REST API (ASP.NET Core, .NET 9), SQL Server, RabbitMQ worker (added in a later module).

## Repository layout

```
AutoServis/            Backend solution, docker-compose.yml, .env.example
  AutoServis.Model/            DTOs (requests, responses, search objects), enums, exceptions, constants
  AutoServis.Common.Services/  Password hashing and secure token helpers
  AutoServis.Services/         Entities, DbContext, migrations, seed data, services, validators
  AutoServis.WebAPI/           Controllers, filters, authentication, Program.cs
UI/                    Flutter applications
  autoservis_desktop/          Windows desktop application for workshop staff
  autoservis_mobile/           Android application for vehicle owners (clients)
```


## Running the backend

1. Copy `AutoServis/.env.example` to `AutoServis/.env` (the values work as they are).
2. Run everything with Docker (database + API):
   ```
   cd AutoServis
   docker compose up --build
   ```
   The API is available at http://localhost:5126/swagger. Migrations and seed data are applied automatically.

   Or run only the database in Docker and the API from the IDE:
   ```
   docker compose up -d db
   dotnet run --project AutoServis.WebAPI
   ```

## Running the desktop application

Requirements: Flutter SDK, Visual Studio with the "Desktop development with C++" workload. The API must be running.

```
cd UI/autoservis_desktop
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d windows --dart-define=API_BASE_URL=http://localhost:5126
```

## Running the mobile application

Requirements: Flutter SDK, Android Studio with an Android emulator (or a phone with USB debugging). The API must be running.

```
cd UI/autoservis_mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5126
```

`10.0.2.2` is the address under which the Android emulator reaches the computer it runs on.
On a physical phone use the IP address of the computer in the local network, for example
`--dart-define=API_BASE_URL=http://192.168.1.20:5126`. In that case run the API with Docker
(`docker compose up --build`), because the API started with `dotnet run` listens on localhost only.

The API address is never hardcoded in either application: it comes from `--dart-define=API_BASE_URL`.

## Test accounts (password for every account: `test`)

| Context            | Username  | Password | Role     |
|--------------------|-----------|----------|----------|
| Desktop application| desktop   | test     | Admin    |
| Mobile application | mobile    | test     | Client   |
| Role: Manager      | manager   | test     | Manager  |
| Role: Mechanic     | mechanic  | test     | Mechanic |

The mobile application accepts only the Client role, the desktop application only the workshop team.
A new client can also register in the mobile application.