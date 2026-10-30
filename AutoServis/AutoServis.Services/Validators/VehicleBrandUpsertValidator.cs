using AutoServis.Model.Requests;
using FluentValidation;

namespace AutoServis.Services.Validators;

public class VehicleBrandUpsertValidator : AbstractValidator<VehicleBrandUpsertRequest>
{
    public VehicleBrandUpsertValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Naziv brenda je obavezan.")
            .MaximumLength(50).WithMessage("Naziv brenda ne može imati više od 50 znakova.");
    }
}