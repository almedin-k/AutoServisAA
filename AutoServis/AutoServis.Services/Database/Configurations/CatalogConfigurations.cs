using AutoServis.Services.Database.Entities;
using AutoServis.Services.Database.Seed;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace AutoServis.Services.Database.Configurations;

public class VehicleBrandConfiguration : IEntityTypeConfiguration<VehicleBrand>
{
    public void Configure(EntityTypeBuilder<VehicleBrand> builder)
    {
        builder.HasKey(b => b.Id);
        builder.Property(b => b.Name).IsRequired().HasMaxLength(50);
        builder.HasIndex(b => b.Name).IsUnique();

        builder.HasData(SeedData.VehicleBrands);
    }
}

public class VehicleConfiguration : IEntityTypeConfiguration<Vehicle>
{
    public void Configure(EntityTypeBuilder<Vehicle> builder)
    {
        builder.HasKey(v => v.Id);
        builder.Property(v => v.Model).IsRequired().HasMaxLength(50);
        builder.Property(v => v.Vin).IsRequired().HasMaxLength(17);

        // A VIN must be unique among vehicles that have not been logically deleted.
        builder.HasIndex(v => v.Vin).IsUnique().HasFilter("[IsDeleted] = 0");

        builder.HasOne(v => v.User)
            .WithMany()
            .HasForeignKey(v => v.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(v => v.Brand)
            .WithMany()
            .HasForeignKey(v => v.BrandId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class ServiceCategoryConfiguration : IEntityTypeConfiguration<ServiceCategory>
{
    public void Configure(EntityTypeBuilder<ServiceCategory> builder)
    {
        builder.HasKey(c => c.Id);
        builder.Property(c => c.Name).IsRequired().HasMaxLength(100);
        builder.Property(c => c.Description).HasMaxLength(500);
        builder.HasIndex(c => c.Name).IsUnique();

        builder.HasData(SeedData.ServiceCategories);
    }
}

public class ServiceConfiguration : IEntityTypeConfiguration<Service>
{
    public void Configure(EntityTypeBuilder<Service> builder)
    {
        builder.HasKey(s => s.Id);
        builder.Property(s => s.Name).IsRequired().HasMaxLength(100);
        builder.Property(s => s.Description).IsRequired().HasMaxLength(1000);
        builder.Property(s => s.Price).HasPrecision(18, 2);

        builder.HasOne(s => s.Category)
            .WithMany()
            .HasForeignKey(s => s.CategoryId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class ServiceImageConfiguration : IEntityTypeConfiguration<ServiceImage>
{
    public void Configure(EntityTypeBuilder<ServiceImage> builder)
    {
        builder.HasKey(i => i.ServiceId);
        builder.Property(i => i.Data).IsRequired();
        builder.Property(i => i.ContentType).IsRequired().HasMaxLength(100);

        builder.HasOne(i => i.Service)
            .WithOne(s => s.Image)
            .HasForeignKey<ServiceImage>(i => i.ServiceId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

public class PartConfiguration : IEntityTypeConfiguration<Part>
{
    public void Configure(EntityTypeBuilder<Part> builder)
    {
        builder.HasKey(p => p.Id);
        builder.Property(p => p.Name).IsRequired().HasMaxLength(100);
        builder.Property(p => p.Sku).HasMaxLength(50);
        builder.Property(p => p.UnitPrice).HasPrecision(18, 2);
    }
}

public class ServicePartConfiguration : IEntityTypeConfiguration<ServicePart>
{
    public void Configure(EntityTypeBuilder<ServicePart> builder)
    {
        builder.HasKey(sp => new { sp.ServiceId, sp.PartId });

        builder.HasOne(sp => sp.Service)
            .WithMany(s => s.ServiceParts)
            .HasForeignKey(sp => sp.ServiceId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(sp => sp.Part)
            .WithMany()
            .HasForeignKey(sp => sp.PartId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class HoistConfiguration : IEntityTypeConfiguration<Hoist>
{
    public void Configure(EntityTypeBuilder<Hoist> builder)
    {
        builder.HasKey(h => h.Id);
        builder.Property(h => h.Name).IsRequired().HasMaxLength(50);

        builder.HasData(SeedData.Hoists);
    }
}

public class ServiceViewConfiguration : IEntityTypeConfiguration<ServiceView>
{
    public void Configure(EntityTypeBuilder<ServiceView> builder)
    {
        builder.HasKey(v => v.Id);
        builder.HasIndex(v => new { v.UserId, v.ServiceId });

        builder.HasOne(v => v.User)
            .WithMany()
            .HasForeignKey(v => v.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(v => v.Service)
            .WithMany()
            .HasForeignKey(v => v.ServiceId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
