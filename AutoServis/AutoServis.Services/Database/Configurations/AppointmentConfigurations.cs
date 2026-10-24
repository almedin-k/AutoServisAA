using AutoServis.Services.Database.Entities;
using AutoServis.Services.Database.Seed;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace AutoServis.Services.Database.Configurations;

public class AppointmentStatusConfiguration : IEntityTypeConfiguration<AppointmentStatus>
{
    public void Configure(EntityTypeBuilder<AppointmentStatus> builder)
    {
        builder.HasKey(s => s.Id);
        builder.Property(s => s.Id).ValueGeneratedNever();
        builder.Property(s => s.Name).IsRequired().HasMaxLength(50);

        builder.HasData(SeedData.AppointmentStatuses);
    }
}

public class ServicePhaseConfiguration : IEntityTypeConfiguration<ServicePhase>
{
    public void Configure(EntityTypeBuilder<ServicePhase> builder)
    {
        builder.HasKey(p => p.Id);
        builder.Property(p => p.Id).ValueGeneratedNever();
        builder.Property(p => p.Name).IsRequired().HasMaxLength(50);

        builder.HasData(SeedData.ServicePhases);
    }
}

public class AppointmentConfiguration : IEntityTypeConfiguration<Appointment>
{
    public void Configure(EntityTypeBuilder<Appointment> builder)
    {
        builder.HasKey(a => a.Id);
        builder.Property(a => a.ServicePrice).HasPrecision(18, 2);
        builder.Property(a => a.ClientNote).HasMaxLength(500);
        builder.Property(a => a.InternalNotes).HasMaxLength(2000);
        builder.Property(a => a.DiagnosticCodes).HasMaxLength(500);
        builder.Property(a => a.CancellationReason).HasMaxLength(500);

        builder.HasIndex(a => a.ClientId);
        builder.HasIndex(a => new { a.MechanicId, a.ScheduledStart });
        builder.HasIndex(a => new { a.HoistId, a.ScheduledStart });
        builder.HasIndex(a => new { a.StatusId, a.ScheduledStart });

        builder.HasOne(a => a.Client)
            .WithMany()
            .HasForeignKey(a => a.ClientId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(a => a.Vehicle)
            .WithMany()
            .HasForeignKey(a => a.VehicleId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(a => a.Service)
            .WithMany()
            .HasForeignKey(a => a.ServiceId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(a => a.Status)
            .WithMany()
            .HasForeignKey(a => a.StatusId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(a => a.Mechanic)
            .WithMany()
            .HasForeignKey(a => a.MechanicId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(a => a.Hoist)
            .WithMany()
            .HasForeignKey(a => a.HoistId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(a => a.ApprovedByUser)
            .WithMany()
            .HasForeignKey(a => a.ApprovedByUserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(a => a.CancelledByUser)
            .WithMany()
            .HasForeignKey(a => a.CancelledByUserId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class AppointmentPartConfiguration : IEntityTypeConfiguration<AppointmentPart>
{
    public void Configure(EntityTypeBuilder<AppointmentPart> builder)
    {
        builder.HasKey(p => p.Id);
        builder.Property(p => p.UnitPrice).HasPrecision(18, 2);

        builder.HasOne(p => p.Appointment)
            .WithMany(a => a.Parts)
            .HasForeignKey(p => p.AppointmentId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(p => p.Part)
            .WithMany()
            .HasForeignKey(p => p.PartId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class AppointmentStatusHistoryConfiguration : IEntityTypeConfiguration<AppointmentStatusHistory>
{
    public void Configure(EntityTypeBuilder<AppointmentStatusHistory> builder)
    {
        builder.HasKey(h => h.Id);
        builder.Property(h => h.Comment).HasMaxLength(500);

        builder.HasOne(h => h.Appointment)
            .WithMany(a => a.StatusHistory)
            .HasForeignKey(h => h.AppointmentId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne<AppointmentStatus>()
            .WithMany()
            .HasForeignKey(h => h.FromStatusId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne<AppointmentStatus>()
            .WithMany()
            .HasForeignKey(h => h.ToStatusId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(h => h.ChangedByUser)
            .WithMany()
            .HasForeignKey(h => h.ChangedByUserId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class ServiceWorkflowConfiguration : IEntityTypeConfiguration<ServiceWorkflow>
{
    public void Configure(EntityTypeBuilder<ServiceWorkflow> builder)
    {
        builder.HasKey(w => w.Id);
        builder.Property(w => w.Note).HasMaxLength(500);

        builder.HasOne(w => w.Appointment)
            .WithMany(a => a.Workflow)
            .HasForeignKey(w => w.AppointmentId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(w => w.Phase)
            .WithMany()
            .HasForeignKey(w => w.PhaseId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(w => w.ChangedByUser)
            .WithMany()
            .HasForeignKey(w => w.ChangedByUserId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class PaymentConfiguration : IEntityTypeConfiguration<Payment>
{
    public void Configure(EntityTypeBuilder<Payment> builder)
    {
        builder.HasKey(p => p.Id);
        builder.Property(p => p.Amount).HasPrecision(18, 2);
        builder.Property(p => p.ChargedAmount).HasPrecision(18, 2);
        builder.Property(p => p.RefundedAmount).HasPrecision(18, 2);
        builder.Property(p => p.ChargedCurrency).IsRequired().HasMaxLength(3);
        builder.Property(p => p.ExternalOrderId).IsRequired().HasMaxLength(100);
        builder.Property(p => p.ExternalCaptureId).HasMaxLength(100);

        builder.HasIndex(p => p.ExternalOrderId).IsUnique();

        builder.HasOne(p => p.Appointment)
            .WithMany(a => a.Payments)
            .HasForeignKey(p => p.AppointmentId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class ReviewConfiguration : IEntityTypeConfiguration<Review>
{
    public void Configure(EntityTypeBuilder<Review> builder)
    {
        builder.HasKey(r => r.Id);
        builder.Property(r => r.Comment).HasMaxLength(1000);

        // Exactly one review per appointment.
        builder.HasIndex(r => r.AppointmentId).IsUnique();

        builder.ToTable(t => t.HasCheckConstraint("CK_Reviews_Rating", "[Rating] BETWEEN 1 AND 5"));

        builder.HasOne(r => r.Appointment)
            .WithMany()
            .HasForeignKey(r => r.AppointmentId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(r => r.Client)
            .WithMany()
            .HasForeignKey(r => r.ClientId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class NotificationConfiguration : IEntityTypeConfiguration<Notification>
{
    public void Configure(EntityTypeBuilder<Notification> builder)
    {
        builder.HasKey(n => n.Id);
        builder.Property(n => n.Title).IsRequired().HasMaxLength(100);
        builder.Property(n => n.Body).IsRequired().HasMaxLength(500);

        builder.HasIndex(n => new { n.UserId, n.IsRead });

        builder.HasOne(n => n.User)
            .WithMany()
            .HasForeignKey(n => n.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(n => n.Appointment)
            .WithMany()
            .HasForeignKey(n => n.AppointmentId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
