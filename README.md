# AutoServisAA

Information system for an auto service: client mobile app (Flutter), administrative desktop app (Flutter Windows),
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
```

## Running the backend

1. Run everything with Docker (database + API):
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

The API address is not hardcoded: it comes from `--dart-define=API_BASE_URL`.

## Test accounts (password for every account is `test`)

| Context            | Username  | Password | Role     |
|--------------------|-----------|----------|----------|
| Desktop application| desktop   | test     | Admin    |
| Mobile application | mobile    | test     | Client   |
| Role: Manager      | manager   | test     | Manager  |
| Role: Mechanic     | mechanic  | test     | Mechanic |
