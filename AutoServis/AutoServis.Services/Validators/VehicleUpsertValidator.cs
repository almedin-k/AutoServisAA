using AutoServis.Model.Enums;
using AutoServis.Model.Requests;
using FluentValidation;

namespace AutoServis.Services.Validators;

public class VehicleUpsertValidator : AbstractValidator<VehicleUpsertRequest>
{
    private const int FirstProductionYear = 1950;

    public VehicleUpsertValidator()
    {
        // The next year model can already be on sale.
        var lastProductionYear = DateTime.UtcNow.Year + 1;

        RuleFor(x => x.BrandId)
            .GreaterThan(0).WithMessage("Odaberite brend vozila.");

        RuleFor(x => x.Model)
            .NotEmpty().WithMessage("Model vozila je obavezan.")
            .MaximumLength(50).WithMessage("Model ne može imati više od 50 znakova.");

        RuleFor(x => x.ProductionYear)
            .InclusiveBetween(FirstProductionYear, lastProductionYear)
            .WithMessage($"Godina proizvodnje mora biti između {FirstProductionYear}. i {lastProductionYear}.");

        RuleFor(x => x.EngineType)
            .IsInEnum().WithMessage("Odaberite vrstu motora.");

        RuleFor(x => x.EngineDisplacementCc)
            .GreaterThan(0).WithMessage("Zapremina motora je obavezna za ovu vrstu motora.")
            .When(x => x.EngineType != EngineType.Electric);

        RuleFor(x => x.EngineDisplacementCc)
            .Equal(0).WithMessage("Električna vozila nemaju zapreminu motora.")
            .When(x => x.EngineType == EngineType.Electric);

        RuleFor(x => x.EngineDisplacementCc)
            .LessThanOrEqualTo(10000).WithMessage("Zapremina motora ne može biti veća od 10.000 cm³.");

        RuleFor(x => x.EnginePowerKw)
            .InclusiveBetween(1, 2000).WithMessage("Snaga motora mora biti između 1 i 2.000 kW.");

        RuleFor(x => x.Vin)
            .NotEmpty().WithMessage("VIN broj je obavezan.")
            .Matches("^[A-HJ-NPR-Za-hj-npr-z0-9]{17}$")
            .WithMessage("VIN mora imati tačno 17 znakova: slova i brojeve, bez slova I, O i Q.");

        RuleFor(x => x.MileageKm)
            .InclusiveBetween(0, 2_000_000).WithMessage("Kilometraža mora biti između 0 i 2.000.000 km.");
    }
}
