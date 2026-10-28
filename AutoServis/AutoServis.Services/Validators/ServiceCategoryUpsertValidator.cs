using AutoServis.Model.Requests;
using FluentValidation;

namespace AutoServis.Services.Validators;

public class ServiceCategoryUpsertValidator : AbstractValidator<ServiceCategoryUpsertRequest>
{
    public ServiceCategoryUpsertValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Naziv kategorije je obavezan.")
            .MaximumLength(100).WithMessage("Naziv kategorije ne može imati više od 100 znakova.");

        RuleFor(x => x.Description)
            .MaximumLength(500).WithMessage("Opis ne može imati više od 500 znakova.");
    }
}
