using AutoServis.Model.Requests;
using FluentValidation;

namespace AutoServis.Services.Validators;

public class CityUpsertValidator : AbstractValidator<CityUpsertRequest>
{
    public CityUpsertValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Naziv grada je obavezan.")
            .MaximumLength(100).WithMessage("Naziv grada ne može imati više od 100 znakova.");

        RuleFor(x => x.PostalCode)
            .Matches("^[0-9]{5}$").WithMessage("Poštanski broj mora imati tačno 5 cifara, na primjer 88000.")
            .When(x => !string.IsNullOrWhiteSpace(x.PostalCode));
    }
}
