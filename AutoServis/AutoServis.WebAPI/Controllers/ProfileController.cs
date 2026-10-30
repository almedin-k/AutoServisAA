using AutoServis.Model.Constants;
using AutoServis.Model.Exceptions;
using AutoServis.Model.Requests;
using AutoServis.Model.Responses;
using AutoServis.Services.Users;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AutoServis.WebAPI.Controllers;

//The account of the signed-in user
[ApiController]
[Route("[controller]")]
[Authorize]
public class ProfileController : ControllerBase
{
    private readonly IProfileService _profileService;
    public ProfileController(IProfileService profileService)
    {
        _profileService = profileService;
    }

    [HttpGet]
    public async Task<ActionResult<ProfileResponse>> Get(CancellationToken cancellationToken)
    {
        return Ok(await _profileService.GetAsync(cancellationToken));
    }

    [HttpPut]
    public async Task<ActionResult<ProfileResponse>> Update(
        [FromBody] UpdateProfileRequest request, CancellationToken cancellationToken)
    {
        return Ok(await _profileService.UpdateAsync(request, cancellationToken));
    }

    [HttpPut("password")]
    public async Task<IActionResult> ChangePassword(
        [FromBody] ChangePasswordRequest request, CancellationToken cancellationToken)
    {
        await _profileService.ChangePasswordAsync(request, cancellationToken);
        return NoContent();
    }

    [HttpGet("image")]
    public async Task<IActionResult> GetImage(CancellationToken cancellationToken)
    {
        var image = await _profileService.GetImageAsync(cancellationToken);
        return File(image.Data, image.ContentType);
    }

    [HttpPut("image")]
    [Consumes("multipart/form-data")]
    public async Task<IActionResult> UploadImage(IFormFile? file, CancellationToken cancellationToken)
    {
        if (file is null || file.Length == 0)
        {
            throw new BusinessException("Odaberite datoteku sa slikom.");
        }

        if (file.Length > ProfileImageRules.MaxBytes)
        {
            throw new BusinessException(
                $"Slika je prevelika. Maksimalna veličina je {ProfileImageRules.MaxBytes / (1024 * 1024)} MB.");
        }

        using var stream = new MemoryStream((int)file.Length);
        await file.CopyToAsync(stream, cancellationToken);

        await _profileService.SetImageAsync(stream.ToArray(), cancellationToken);
        return NoContent();
    }

    [HttpDelete("image")]
    public async Task<IActionResult> DeleteImage(CancellationToken cancellationToken)
    {
        await _profileService.DeleteImageAsync(cancellationToken);
        return NoContent();
    }
}