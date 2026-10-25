using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace AutoServis.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class ServiceCatalogAdded : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Services_CategoryId",
                table: "Services");

            migrationBuilder.InsertData(
                table: "Parts",
                columns: new[] { "Id", "IsActive", "Name", "Sku", "UnitPrice" },
                values: new object[,]
                {
                    { 1, true, "Engine oil 5W-30 (5 L)", "OIL-5W30-5L", 55.00m },
                    { 2, true, "Oil filter", "FLT-OIL-STD", 12.00m },
                    { 3, true, "Air filter", "FLT-AIR-STD", 18.00m },
                    { 4, true, "Cabin (pollen) filter", "FLT-CAB-STD", 15.00m },
                    { 5, true, "Fuel filter", "FLT-FUEL-STD", 28.00m },
                    { 6, true, "Front brake pads (set)", "BRK-PAD-FR", 65.00m },
                    { 7, true, "Rear brake pads (set)", "BRK-PAD-RR", 55.00m },
                    { 8, true, "Front brake discs (pair)", "BRK-DSC-FR", 140.00m },
                    { 9, true, "Brake fluid DOT 4 (1 L)", "BRK-FLD-1L", 14.00m },
                    { 10, true, "A/C refrigerant R134a (500 g)", "AC-R134A-500", 35.00m },
                    { 11, true, "Spark plug", "IGN-SPK-STD", 12.00m },
                    { 12, true, "Timing belt kit", "TMG-KIT-STD", 220.00m },
                    { 13, true, "Coolant (5 L)", "CLT-5L", 25.00m },
                    { 14, true, "Glow plug", "IGN-GLW-STD", 22.00m }
                });

            migrationBuilder.InsertData(
                table: "Services",
                columns: new[] { "Id", "CategoryId", "CreatedAt", "Description", "DurationMinutes", "HasImage", "IsActive", "Name", "Price", "UpdatedAt", "WarrantyMonths" },
                values: new object[,]
                {
                    { 1, 1, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Engine oil and oil filter replacement with a basic visual inspection of the vehicle.", 60, false, true, "Small Service", 140.00m, null, 3 },
                    { 2, 1, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Oil, oil filter, air filter, cabin filter and fuel filter replacement with a full inspection of the vehicle.", 150, false, true, "Large Service", 320.00m, null, 6 },
                    { 3, 1, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Detailed inspection of a vehicle you plan to buy, with a written report of the findings.", 60, false, true, "Pre-purchase Inspection", 60.00m, null, 0 },
                    { 4, 2, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Replacement of the front brake pads and a check of the discs and brake lines.", 60, false, true, "Front Brake Pads Replacement", 90.00m, null, 12 },
                    { 5, 2, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Replacement of the rear brake pads and a check of the discs and handbrake.", 60, false, true, "Rear Brake Pads Replacement", 80.00m, null, 12 },
                    { 6, 2, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Replacement of the front brake discs together with new brake pads.", 120, false, true, "Front Brake Discs and Pads Replacement", 210.00m, null, 12 },
                    { 7, 2, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Complete replacement of the brake fluid and bleeding of the brake system.", 45, false, true, "Brake Fluid Replacement", 55.00m, null, 6 },
                    { 8, 3, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Scanning of all electronic control units, reading of fault codes and live sensor data, with a written report.", 45, false, true, "Complete Computer Diagnostics", 50.00m, null, 0 },
                    { 9, 3, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Quick reading and clearing of fault codes with an explanation of what each code means.", 20, false, true, "Fault Code Reading and Reset", 25.00m, null, 0 },
                    { 10, 4, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Leak check, refrigerant refill and cabin filter replacement for an efficient climate system.", 60, false, true, "Air Conditioning Service and Refill", 90.00m, null, 6 },
                    { 11, 4, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Cleaning and disinfection of the climate system to remove bacteria and unpleasant odours.", 30, false, true, "Air Conditioning Disinfection", 45.00m, null, 0 },
                    { 12, 5, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Replacement of the timing belt kit and coolant, including a check of the related components.", 240, false, true, "Timing Belt Replacement", 280.00m, null, 12 },
                    { 13, 5, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Draining and refilling of the cooling system with new coolant.", 60, false, true, "Coolant Replacement", 70.00m, null, 6 },
                    { 14, 5, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Replacement of the spark plugs on petrol engines.", 45, false, true, "Spark Plug Replacement", 60.00m, null, 6 },
                    { 15, 6, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Optimisation of the engine control unit software for better response and efficiency, with a before and after test.", 180, false, true, "ECU Remap Stage 1", 450.00m, null, 12 },
                    { 16, 6, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Reading of the original ECU software and storing a backup, so the vehicle can always be returned to stock.", 60, false, true, "ECU Reading and Backup", 100.00m, null, 0 }
                });

            migrationBuilder.InsertData(
                table: "ServiceParts",
                columns: new[] { "PartId", "ServiceId", "Quantity" },
                values: new object[,]
                {
                    { 1, 1, 1 },
                    { 2, 1, 1 },
                    { 1, 2, 1 },
                    { 2, 2, 1 },
                    { 3, 2, 1 },
                    { 4, 2, 1 },
                    { 5, 2, 1 },
                    { 6, 4, 1 },
                    { 7, 5, 1 },
                    { 6, 6, 1 },
                    { 8, 6, 1 },
                    { 9, 7, 2 },
                    { 4, 10, 1 },
                    { 10, 10, 1 },
                    { 12, 12, 1 },
                    { 13, 12, 1 },
                    { 13, 13, 1 },
                    { 11, 14, 4 }
                });

            migrationBuilder.CreateIndex(
                name: "IX_Services_CategoryId_Name",
                table: "Services",
                columns: new[] { "CategoryId", "Name" },
                unique: true);

            migrationBuilder.AddCheckConstraint(
                name: "CK_ServiceParts_Quantity",
                table: "ServiceParts",
                sql: "[Quantity] > 0");

            migrationBuilder.CreateIndex(
                name: "IX_Parts_Sku",
                table: "Parts",
                column: "Sku",
                unique: true,
                filter: "[Sku] IS NOT NULL");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Services_CategoryId_Name",
                table: "Services");

            migrationBuilder.DropCheckConstraint(
                name: "CK_ServiceParts_Quantity",
                table: "ServiceParts");

            migrationBuilder.DropIndex(
                name: "IX_Parts_Sku",
                table: "Parts");

            migrationBuilder.DeleteData(
                table: "Parts",
                keyColumn: "Id",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "ServiceParts",
                keyColumns: new[] { "PartId", "ServiceId" },
                keyValues: new object[] { 1, 1 });

            migrationBuilder.DeleteData(
                table: "ServiceParts",
                keyColumns: new[] { "PartId", "ServiceId" },
                keyValues: new object[] { 2, 1 });

            migrationBuilder.DeleteData(
                table: "ServiceParts",
                keyColumns: new[] { "PartId", "ServiceId" },
                keyValues: new object[] { 1, 2 });

            migrationBuilder.DeleteData(
                table: "ServiceParts",
                keyColumns: new[] { "PartId", "ServiceId" },
                keyValues: new object[] { 2, 2 });

            migrationBuilder.DeleteData(
                table: "ServiceParts",
                keyColumns: new[] { "PartId", "ServiceId" },
                keyValues: new object[] { 3, 2 });

            migrationBuilder.DeleteData(
                table: "ServiceParts",
                keyColumns: new[] { "PartId", "ServiceId" },
                keyValues: new object[] { 4, 2 });

            migrationBuilder.DeleteData(
                table: "ServiceParts",
                keyColumns: new[] { "PartId", "ServiceId" },
                keyValues: new object[] { 5, 2 });

            migrationBuilder.DeleteData(
                table: "ServiceParts",
                keyColumns: new[] { "PartId", "ServiceId" },
                keyValues: new object[] { 6, 4 });

            migrationBuilder.DeleteData(
                table: "ServiceParts",
                keyColumns: new[] { "PartId", "ServiceId" },
                keyValues: new object[] { 7, 5 });

            migrationBuilder.DeleteData(
                table: "ServiceParts",
                keyColumns: new[] { "PartId", "ServiceId" },
                keyValues: new object[] { 6, 6 });

            migrationBuilder.DeleteData(
                table: "ServiceParts",
                keyColumns: new[] { "PartId", "ServiceId" },
                keyValues: new object[] { 8, 6 });

            migrationBuilder.DeleteData(
                table: "ServiceParts",
                keyColumns: new[] { "PartId", "ServiceId" },
                keyValues: new object[] { 9, 7 });

            migrationBuilder.DeleteData(
                table: "ServiceParts",
                keyColumns: new[] { "PartId", "ServiceId" },
                keyValues: new object[] { 4, 10 });

            migrationBuilder.DeleteData(
                table: "ServiceParts",
                keyColumns: new[] { "PartId", "ServiceId" },
                keyValues: new object[] { 10, 10 });

            migrationBuilder.DeleteData(
                table: "ServiceParts",
                keyColumns: new[] { "PartId", "ServiceId" },
                keyValues: new object[] { 12, 12 });

            migrationBuilder.DeleteData(
                table: "ServiceParts",
                keyColumns: new[] { "PartId", "ServiceId" },
                keyValues: new object[] { 13, 12 });

            migrationBuilder.DeleteData(
                table: "ServiceParts",
                keyColumns: new[] { "PartId", "ServiceId" },
                keyValues: new object[] { 13, 13 });

            migrationBuilder.DeleteData(
                table: "ServiceParts",
                keyColumns: new[] { "PartId", "ServiceId" },
                keyValues: new object[] { 11, 14 });

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "Parts",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Parts",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Parts",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Parts",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Parts",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Parts",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Parts",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Parts",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Parts",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Parts",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Parts",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Parts",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Parts",
                keyColumn: "Id",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Services",
                keyColumn: "Id",
                keyValue: 14);

            migrationBuilder.CreateIndex(
                name: "IX_Services_CategoryId",
                table: "Services",
                column: "CategoryId");
        }
    }
}
