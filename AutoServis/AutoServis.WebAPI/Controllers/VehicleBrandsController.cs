using AutoServis.Model.Requests;
using AutoServis.Model.Responses;
using AutoServis.Model.SearchObjects;
using AutoServis.Services.Vehicles;

namespace AutoServis.WebAPI.Controllers;

public class VehicleBrandsController
    : BaseCRUDController<VehicleBrandResponse, VehicleBrandSearchObject, VehicleBrandUpsertRequest, VehicleBrandUpsertRequest, IVehicleBrandService>
{
    public VehicleBrandsController(IVehicleBrandService service) : base(service)
    {
    }
}