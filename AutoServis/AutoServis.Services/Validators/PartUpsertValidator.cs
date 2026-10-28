using AutoServis.Model.Requests;
using FluentValidation;

namespace AutoServis.Services.Validators;

public class PartUpsertValidator : AbstractValidator<PartUpsertRequest>
{
    public PartUpsertValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Naziv dijela je obavezan.")
            .MaximumLength(100).WithMessage("Naziv dijela ne može imati više od 100 znakova.");

        RuleFor(x => x.Sku)
            .MaximumLength(50).WithMessage("SKU oznaka ne može imati više od 50 znakova.")
            .Matches("^[A-Za-z0-9._-]+$").WithMessage("SKU oznaka može sadržavati samo slova, brojeve, tačke, crtice i donje crte.")
            .When(x => !string.IsNullOrWhiteSpace(x.Sku));

        RuleFor(x => x.UnitPrice)
            .GreaterThanOrEqualTo(0).WithMessage("Jedinična cijena ne može biti negativna.")
            .LessThanOrEqualTo(100000).WithMessage("Jedinična cijena ne može biti veća od 100.000 KM.")
            .Must(price => decimal.Round(price, 2) == price).WithMessage("Jedinična cijena može imati najviše 2 decimalna mjesta.");
    }
}
