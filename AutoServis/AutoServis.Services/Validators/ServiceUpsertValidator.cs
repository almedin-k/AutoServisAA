using AutoServis.Model.Requests;
using FluentValidation;

namespace AutoServis.Services.Validators;

public class ServiceUpsertValidator : AbstractValidator<ServiceUpsertRequest>
{
    public ServiceUpsertValidator()
    {
        RuleFor(x => x.CategoryId)
            .GreaterThan(0).WithMessage("Odaberite kategoriju.");

        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Naziv usluge je obavezan.")
            .MaximumLength(100).WithMessage("Naziv usluge ne može imati više od 100 znakova.");

        RuleFor(x => x.Description)
            .NotEmpty().WithMessage("Opis je obavezan.")
            .MaximumLength(1000).WithMessage("Opis ne može imati više od 1000 znakova.");

        RuleFor(x => x.Price)
            .GreaterThan(0).WithMessage("Cijena mora biti veća od 0 KM.")
            .LessThanOrEqualTo(100000).WithMessage("Cijena ne može biti veća od 100.000 KM.")
            .Must(price => decimal.Round(price, 2) == price).WithMessage("Cijena može imati najviše 2 decimalna mjesta.");

        RuleFor(x => x.DurationMinutes)
            .InclusiveBetween(5, 720).WithMessage("Trajanje mora biti između 5 i 720 minuta.")
            .Must(minutes => minutes % 5 == 0).WithMessage("Trajanje mora biti djelioc broja 5 (npr.5, 10, 15, 45, 115...).");

        RuleFor(x => x.WarrantyMonths)
            .InclusiveBetween(0, 60).WithMessage("Garancija mora biti između 0 i 60 mjeseci.");

        RuleFor(x => x.RequiredParts)
            .Cascade(CascadeMode.Stop)
            .NotNull().WithMessage("Lista potrebnih dijelova nedostaje.")
            .Must(parts => parts.Count <= 30).WithMessage("Usluga može imati najviše 30 potrebnih dijelova.")
            .Must(parts => parts.Select(p => p.PartId).Distinct().Count() == parts.Count)
            .WithMessage("Isti dio se ne može dodati dvaput.");

        RuleForEach(x => x.RequiredParts).ChildRules(part =>
        {
            part.RuleFor(p => p.PartId).GreaterThan(0).WithMessage("Odaberite dio.");
            part.RuleFor(p => p.Quantity).InclusiveBetween(1, 100).WithMessage("Količina dijela mora biti između 1 i 100.");
        });
    }
}
