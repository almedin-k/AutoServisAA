using AutoServis.Model.Requests;
using FluentValidation;

namespace AutoServis.Services.Validators;

public class ServiceCategoryUpsertValidator : AbstractValidator<ServiceCategoryUpsertRequest>
{
    public ServiceCategoryUpsertValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Category name is required.")
            .MaximumLength(100).WithMessage("Category name cannot be longer than 100 characters.");

        RuleFor(x => x.Description)
            .MaximumLength(500).WithMessage("Description cannot be longer than 500 characters.");
    }
}
