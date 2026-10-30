using AutoServis.Model.Requests;
using AutoServis.Model.Responses;
using AutoServis.Model.SearchObjects;

namespace AutoServis.Services.Vehicles;
public interface IVehicleBrandService
    : IBaseCRUDService<VehicleBrandResponse, VehicleBrandSearchObject, VehicleBrandUpsertRequest, VehicleBrandUpsertRequest>
{
}