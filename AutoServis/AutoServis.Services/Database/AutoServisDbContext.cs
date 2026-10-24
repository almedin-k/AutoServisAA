using AutoServis.Services.Database.Entities;
using Microsoft.EntityFrameworkCore;

namespace AutoServis.Services.Database;

public class AutoServisDbContext : DbContext
{
    public AutoServisDbContext(DbContextOptions<AutoServisDbContext> options) : base(options)
    {
    }

    public DbSet<City> Cities => Set<City>();
    public DbSet<Role> Roles => Set<Role>();
    public DbSet<User> Users => Set<User>();
    public DbSet<UserRole> UserRoles => Set<UserRole>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<VehicleBrand> VehicleBrands => Set<VehicleBrand>();
    public DbSet<Vehicle> Vehicles => Set<Vehicle>();
    public DbSet<ServiceCategory> ServiceCategories => Set<ServiceCategory>();
    public DbSet<Service> Services => Set<Service>();
    public DbSet<ServiceImage> ServiceImages => Set<ServiceImage>();
    public DbSet<Part> Parts => Set<Part>();
    public DbSet<ServicePart> ServiceParts => Set<ServicePart>();
    public DbSet<Hoist> Hoists => Set<Hoist>();
    public DbSet<ServiceView> ServiceViews => Set<ServiceView>();
    public DbSet<AppointmentStatus> AppointmentStatuses => Set<AppointmentStatus>();
    public DbSet<ServicePhase> ServicePhases => Set<ServicePhase>();
    public DbSet<Appointment> Appointments => Set<Appointment>();
    public DbSet<AppointmentPart> AppointmentParts => Set<AppointmentPart>();
    public DbSet<AppointmentStatusHistory> AppointmentStatusHistories => Set<AppointmentStatusHistory>();
    public DbSet<ServiceWorkflow> ServiceWorkflows => Set<ServiceWorkflow>();
    public DbSet<Payment> Payments => Set<Payment>();
    public DbSet<Review> Reviews => Set<Review>();
    public DbSet<Notification> Notifications => Set<Notification>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AutoServisDbContext).Assembly);
    }
}
