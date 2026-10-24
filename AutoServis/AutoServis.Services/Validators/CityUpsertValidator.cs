using AutoServis.Model.Requests;
using FluentValidation;

namespace AutoServis.Services.Validators;

public class CityUpsertValidator : AbstractValidator<CityUpsertRequest>
{
    public CityUpsertValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("City name is required.")
            .MaximumLength(100).WithMessage("City name cannot be longer than 100 characters.");

        RuleFor(x => x.PostalCode)
            .Matches("^[0-9]{5}$").WithMessage("Postal code must contain exactly 5 digits, for example 88000.")
            .When(x => !string.IsNullOrWhiteSpace(x.PostalCode));
    }
}
