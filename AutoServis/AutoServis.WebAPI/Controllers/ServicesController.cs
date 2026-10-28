using AutoServis.Model.Constants;
using AutoServis.Model.Exceptions;
using AutoServis.Model.Requests;
using AutoServis.Model.Responses;
using AutoServis.Model.SearchObjects;
using AutoServis.Services.Catalog;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AutoServis.WebAPI.Controllers;

public class ServicesController
    : BaseCRUDController<ServiceResponse, ServiceSearchObject, ServiceUpsertRequest, ServiceUpsertRequest, IServiceService>
{
    public ServicesController(IServiceService service) : base(service)
    {
    }

    [HttpGet("{id:int}/image")]
    [AllowAnonymous]
    [ResponseCache(Duration = 60)]
    public async Task<IActionResult> GetImage(int id, CancellationToken cancellationToken)
    {
        var image = await Service.GetImageAsync(id, cancellationToken);
        return File(image.Data, image.ContentType);
    }

    [HttpPut("{id:int}/image")]
    [Authorize(Roles = Roles.Staff)]
    [Consumes("multipart/form-data")]
    public async Task<IActionResult> UploadImage(int id, IFormFile? file, CancellationToken cancellationToken)
    {
        if (file is null || file.Length == 0)
        {
            throw new BusinessException("Odaberite datoteku sa slikom.");
        }

        if (file.Length > ServiceImageRules.MaxBytes)
        {
            throw new BusinessException(
                $"Slika je prevelika. Maksimalna veličina je {ServiceImageRules.MaxBytes / (1024 * 1024)} MB.");
        }

        using var stream = new MemoryStream((int)file.Length);
        await file.CopyToAsync(stream, cancellationToken);

        await Service.SetImageAsync(id, stream.ToArray(), cancellationToken);
        return NoContent();
    }

    [HttpDelete("{id:int}/image")]
    [Authorize(Roles = Roles.Staff)]
    public async Task<IActionResult> DeleteImage(int id, CancellationToken cancellationToken)
    {
        await Service.DeleteImageAsync(id, cancellationToken);
        return NoContent();
    }
}
